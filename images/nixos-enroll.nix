{ config, pkgs, lib, ... }:

let
  openSslConf = pkgs.writeTextFile {
    name = "openssl.cnf";
    text = ''
      openssl_conf = SSL_Configuration
      [ SSL_Configuration ]
      engines = SSL_Engines
      [ SSL_Engines ]
      pkcs11 = pkcs11_sect
      [pkcs11_sect]
      dynamic_path = ${pkgs.libp11}/lib/engines/pkcs11.so
      MODULE_PATH = ${pkgs.yubico-piv-tool}/lib/libykcs11.so
    '';
  };
  enrollScript = pkgs.writeShellApplication {
    name = "enroll.sh";
    runtimeInputs = with pkgs;
      [
        forgectl
        libp11
        mokutil
        nettools
        openssl
        tpm2-tools
        yubico-piv-tool
      ];
    text = ''
      export VAULT_ADDR="https://vault.cri.epita.fr"

      # This value is in fact a confirmation code, not a real password. It doesn't
      # need to be kept secret.
      MOK_CODE="12345678"

      log() {
          echo "$@" >&2
      }

      get_nvram_handle() {
          forgectl cert security-class --store "$1" --format nvram
      }

      get_key_handle() {
          forgectl cert security-class --store "$1" --format key
      }

      waitForEnrollmentKey() {
          log "Enrolling $(hostname)"
          log "Waiting for enrollment key..."
          while ! yubico-piv-tool -a status > /dev/null 2>&1; do
              log -n "."
              sleep 1
          done
          log
          yubico-piv-tool -a status >&2

          log "Looking up enrollment certificate..."
          for s in $(yubico-piv-tool -a status | grep -Po '(?<=^Slot\s)..'); do
              if yubico-piv-tool -a read-certificate -s "$s" \
                  | openssl x509 -noout -ext subjectAltName \
                  | grep 'forge:role:hosts-enroller' > /dev/null; then
                  slot="$s"
                  if ! [ -f /tmp/autopin ]; then
                      autopin="$(yubico-piv-tool -a read-certificate -s "$s" \
                          | openssl x509 -noout -ext subjectAltName \
                          | grep -Po '(?<=URI:forge:autopin:)[^,\s]*')"
                      touch /tmp/autopin
                  else
                      autopin=""
                  fi
                  return
              fi
          done

          log "ERROR: No enrollment certificate found on key"
          return 1
      }

      tpmInit() {
          log "Clearing TPM old data..."
          tpm2_flushcontext -tl
          tpm2_clear
      }

      computePcr7() {
          log "Current PCR7 value: $(forgectl tpm2 compute-pcr7)"
          for scope in misc regular exam; do
              forgectl tpm2 compute-pcr7 -c "${../certs/public}/$scope.crt" -f policy > "./$scope.policy"
          done
      }

      certLogin() {
          OPENSSL_CONF="${openSslConf}" forgectl vault cert-login "yk:$slot" \
            hosts-enrollment --dont-write-token --print-token --pin "$autopin"
      }

      newCreds() {
          VAULT_TOKEN="$(certLogin)"
          export VAULT_TOKEN

          AK_HANDLE="0x8100C200"
          MISC_NVRAM_HANDLE="$(get_nvram_handle "${../certs/public}/misc.crt")"
          MISC_KEY_HANDLE="$(get_key_handle "${../certs/public}/misc.crt")"
          REGULAR_NVRAM_HANDLE="$(get_nvram_handle "${../certs/public}/regular.crt")"
          REGULAR_KEY_HANDLE="$(get_key_handle "${../certs/public}/regular.crt")"
          EXAM_NVRAM_HANDLE="$(get_nvram_handle "${../certs/public}/exam.crt")"
          EXAM_KEY_HANDLE="$(get_key_handle "${../certs/public}/exam.crt")"

          log "Generating vault credentials..."
          forgectl vault new-approle-credentials --scope misc \
              --store "tpm2:$MISC_NVRAM_HANDLE" --policy misc.policy
          forgectl vault new-approle-credentials --scope regular \
              --store "tpm2:$REGULAR_NVRAM_HANDLE" --policy regular.policy
          forgectl vault new-approle-credentials --scope exam \
              --store "tpm2:$EXAM_NVRAM_HANDLE" --policy exam.policy

          log "Generating host certificates..."
          forgectl host new-certificate --scope regular --store vault:certificate
          forgectl host new-certificate --scope exam --store vault:certificate

          log "Generating host SSH keys"
          forgectl host new-ssh-keys --store file:./ssh_keys
          forgectl store write vault:ssh-keys --scope regular < ./ssh_keys
          forgectl store write vault:ssh-keys --scope exam < ./ssh_keys
          rm ./ssh_keys

          # log "Generating host keytab"
          # TODO

          log "Exporting TPM public keys to Vault"
          forgectl tpm2 export-keys | forgectl store write vault:tpm-keys

          forgectl tpm2 create-ak --store vault:tpm-keys \
              --key attestation_key --name ak "$AK_HANDLE"

          forgectl tpm2 create-key --store vault:tpm-keys \
              --key key_misc --name misc "$MISC_KEY_HANDLE" \
              --policy misc.policy
          forgectl tpm2 create-key --store vault:tpm-keys \
              --key key_regular --name regular "$REGULAR_KEY_HANDLE" \
              --policy regular.policy
          forgectl tpm2 create-key --store vault:tpm-keys \
              --key key_exam --name exam "$EXAM_KEY_HANDLE" \
              --policy exam.policy

          unset VAULT_TOKEN
      }

      mokutil --generate-hash="$MOK_CODE" > ./mok-code

      mokchanged=0
      for cert in root misc regular exam; do
          openssl x509 -in "${../certs/public}/$cert.crt" -out "./$cert.der" -outform der
          # Test fails when key is already enrolled
          if mokutil --test-key "./$cert.der" > /dev/null; then
              log "Importing $cert certificate in MOK database..."
              mokutil --import "./$cert.der" --hash-file ./mok-code
              mokchanged=1
          fi
      done

      if mokutil --sb-state | grep -q 'SecureBoot validation is disabled in shim'; then
          log "Enable SecureBoot validation in shim..."
          mokutil --enable-validation --hash-file ./mok-code
          mokchanged=1
      elif mokutil --sb-state | grep -q 'SecureBoot enabled'; then
          tpmInit
          computePcr7
          waitForEnrollmentKey

          log "Waiting for network to be ready..."
          ${pkgs.nixpie-utils}/bin/get_ip.sh > /dev/null

          newCreds

          log "Enrollment done, powering off in 10 seconds..."
          sleep 10
          ${pkgs.systemd}/bin/systemctl poweroff
      fi

      if [ "$mokchanged" -eq 1 ]; then
          log "MOK database changed, please run mmx64.efi"
          log "Rebooting in 10 seconds..."
          sleep 10
          ${pkgs.systemd}/bin/systemctl reboot
      fi

      log "ERROR: SecureBoot is disabled"
      log Rebooting to UEFI setup in 10 seconds...
      sleep 10
      ${pkgs.systemd}/bin/systemctl reboot --firmware-setup

    '';
  };
  execScript = pkgs.writeShellScript "exec.sh" ''
    set -u

    while true; do
        ${enrollScript}/bin/enroll.sh || true
        echo "Shutdown in 10s"
        read -t 10 -p "Shutdown in 10 seconds, Hit ENTER to retry" && continue
        ${pkgs.systemd}/bin/systemctl poweroff
    done
  '';
in
{
  netboot = {
    enable = true;
    bootcache.enable = lib.mkForce false;
    nix-store-rw.enable = lib.mkForce false;
    home.enable = lib.mkForce false;
    swap.enable = lib.mkForce false;
  };

  cri = {
    afs.enable = false;
    krb5.enable = false;
    ldap.enable = false;
    users.createEpitaUser = false;
  };

  services.getty = {
    loginProgram = "${pkgs.bash}/bin/bash";
    loginOptions = "--login ${execScript}";
    autologinUser = "root";
  };
}
