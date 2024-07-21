{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.cri.fetchHostSecrets;
  fetchHostSecrets = pkgs.writeShellApplication {
    name = "fetch-host-secrets";
    runtimeInputs = [
      pkgs.forgectl
      pkgs.jq
      pkgs.tpm2-tools
    ];
    text = ''
      umask 0077

      if ! current_cert="$(forgectl tpm2 get-current-cert)"; then
          echo "ERROR: unable to read current certificate, SecureBoot may be disabled"
          exit 1
      fi

      secclass="$(echo "$current_cert" | forgectl cert security-class -f name)"
      nvram="$(echo "$current_cert" | forgectl cert security-class -f nvram)"

      echo "Current security class: $secclass"
      echo "$secclass" > /etc/security-class

      for _ in $(seq 5); do
          echo "Logging into Vault server ($VAULT_ADDR)..."
          if VAULT_TOKEN="$(forgectl vault approle-login "tpm2:$nvram" \
              --scope "$secclass" --with-policy --print-token \
              --dont-write-token)"; then
              break
          fi
          sleep 5
      done
      if [ -z "$VAULT_TOKEN" ]; then
          echo "ERROR: unable to get vault token"
          exit 1
      fi
      export VAULT_TOKEN

      # Lock nvram so that it cannot be read again until next reboot
      forgectl store read "tpm2:$nvram" --with-policy --lock > /dev/null

      ssh_keys="$(forgectl store read vault:ssh-keys --scope "$secclass")"
      if [ "$ssh_keys" != "{}" ] && [ -n "$ssh_keys" ]; then
          echo "SSH keys found"
          for filename in $(echo "$ssh_keys" | jq -r 'keys[]'); do
              echo "$ssh_keys" | jq -r ".\"$filename\"" > "/etc/ssh/$filename"
          done
      else
          echo "SSH keys: NOT FOUND"
      fi

      mkdir -p /etc/ssl/private
      host_cert="$(forgectl store read vault:certificate --scope "$secclass")"
      if [ "$host_cert" != "{}" ] && [ -n "$host_cert" ]; then
          echo "Host certificate: found"
          umask 002
          echo "$host_cert" | jq -r '.cert' > /etc/ssl/host-certificate.pem
          echo "$host_cert" | jq -r '.fullchain' > /etc/ssl/host-fullchain.pem

          umask 077
          echo "$host_cert" | jq -r '.key' > /etc/ssl/private/host-key.pem
      else
          echo "Host certificate: NOT FOUND"
      fi

      keytab="$(forgectl store read vault:keytab --scope "$secclass" --key krb5.keytab)"
      if [ -n "$keytab" ]; then
          echo "Host keytab: found"
          echo "$keytab" > /etc/krb5.keytab
      else
          echo "Host keytab: NOT FOUND"
      fi

      unset VAULT_TOKEN
    '';
  };
in
{
  options = {
    cri.fetchHostSecrets = {
      enable = mkEnableOption "fetchHostSecrets";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.fetch-host-secrets = {
      description = "Fetch host secrets from Vault";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      before = [ "sshd.service" ];

      # TPM has been locked upon first execution, service cannot be restarted
      restartIfChanged = false;

      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
      };

      environment = {
        VAULT_ADDR = "https://192.168.1.75:8200";
        REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      };

      preStart = ''
        # We're just waiting for an IP to appear, we don't actually care about
        # it here
        ${pkgs.nixpie-utils}/bin/get_ip.sh > /dev/null
      '';

      script = ''
        exec ${fetchHostSecrets}/bin/fetch-host-secrets
      '';
    };
  };
}
