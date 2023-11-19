{ config, pkgs, lib, inputs, system, ... }:

with lib;
let
  nixosVM = configuration: (import "${inputs.nixpkgs}/nixos" { inherit system configuration; }).vm;
  rootConfig = config.users.users.root;
  vmAttributes = config.cri.packages.pkgs.docker-vm.vmAttributes;
  vmConfig = { config, pkgs, lib, ... }: recursiveUpdate
    vmAttributes
    {
      networking = {
        defaultGateway = "192.168.42.0";
        firewall.enable = false;
        interfaces.eth0.ipv4.addresses = [
          {
            address = "192.168.42.1";
            prefixLength = 31;
          }
        ];
        nameservers = [ "1.1.1.1" ];
      };

      users.users.root = rootConfig;

      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "yes";
          PasswordAuthentication = false;
        };
      };

      systemd.services.mount-user-home = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        serviceConfig.ExecStart =
          let
            script = pkgs.writeScript "docker-vm-mount" ''
              #!${pkgs.runtimeShell}
              set -e
              mkdir -p /tmp/docker-vm-meta
              ${pkgs.mount}/bin/mount -t 9p -o trans=virtio vm_meta "/tmp/docker-vm-meta"

              if [ ! -e /tmp/docker-vm-meta/login ]; then
                echo "No login file found"
                exit 0
              fi

              LOGIN="$(cat /tmp/docker-vm-meta/login)"
              USER_HOME="/home/$LOGIN"

              mkdir -p "$USER_HOME"
              ${pkgs.mount}/bin/mount -t 9p -o trans=virtio user_home "$USER_HOME"
            '';
          in
          "${script}";
      };

      virtualisation = {
        docker = {
          enable = true;
          listenOptions = [
            "0.0.0.0:2375"
          ];
        };
        # We need to force to remove default networking options
        vmVariant.virtualisation.qemu.networkingOptions = lib.mkForce [
          "\${QEMU_NET_OPTS}"
        ];
      };
    };
  builtVM = nixosVM vmConfig;
in
{
  options = {
    cri.packages.pkgs.docker-vm = {
      enable = mkEnableOption "Enable docker vm";
      mountUserHome = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to mount the user home directory in the docker vm.
          This is useful to share files between the host and the docker vm.
        '';
      };
      vmAttributes = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Attributes to be passed to the configuration of the docker vm.
        '';
      };
    };
  };

  config = mkIf config.cri.packages.pkgs.docker-vm.enable {
    cri = {
      pam_hooks = {
        enable = mkDefault true;
        openSessionHooks = [
          "systemctl start docker-vm@\"$PAM_USER\""
        ];
        closeSessionHooks = [
          "systemctl stop docker-vm@\"$PAM_USER\""
        ];
      };
    };

    environment = {
      variables.DOCKER_HOST = "tcp://192.168.42.1:2375";
      systemPackages = with pkgs; [
        docker-client
        builtVM
      ];
    };

    networking = {
      hosts = {
        "192.168.42.1" = [
          "docker.local"
        ];
      };
      interfaces.vdockervm = {
        virtual = true;
        ipv4.addresses = [
          {
            address = "192.168.42.0";
            prefixLength = 31;
          }
        ];
      };
      nat = {
        enable = true;
        internalInterfaces = [ "vdockervm" ];
      };
    };

    systemd.services = {
      "docker-vm-setup" = {
        after = [ "network.target" ];
        script = ''
          TMP_DIR="/tmp/docker-vm"
          mkdir -p "$TMP_DIR"
          chmod 700 "$TMP_DIR"
        '';
        serviceConfig.Type = "oneshot";
        wantedBy = [ "multi-user.target" ];
      };
      "docker-vm@" = {
        after = [ "network.target" ];
        environment = {
          QEMU_NET_OPTS = "-netdev
          tap,id=dockervm0,ifname=vdockervm,script=no,downscript=no -device virtio-net,netdev=dockervm0";
          QEMU_OPTS = "-m 1024 -nographic";
        };
        path = [ builtVM ];
        serviceConfig = {
          ExecStart =
            let
              script = pkgs.writeScript "docker-vm-start" ''
                #!${pkgs.runtimeShell}
                set -e

                USER="$1"
                USER_UID="$(id -u $USER)"

                export NIX_DISK_IMAGE="/tmp/docker-vm/storage_$USER_UID.qcow2"

                # If NIX_DISK_IMAGE exists, delete it
                if [ -e $NIX_DISK_IMAGE ]; then
                  rm $NIX_DISK_IMAGE
                fi

                USER_META_DIR="/tmp/docker-vm/meta_$USER_UID"

                if [ ! -d $USER_META_DIR ]; then
                  mkdir -p $USER_META_DIR
                fi

                QEMU_OPTS="$QEMU_OPTS -virtfs local,path=$USER_META_DIR,security_model=none,mount_tag=vm_meta"

                ${lib.optionalString config.cri.packages.pkgs.docker-vm.mountUserHome ''
                  USER_HOME="/home/$USER"
                  echo "$USER" > "$USER_META_DIR/login"

                  # Check if the user home exists
                  if [ ! -d $USER_HOME ]; then
                    echo "User home does not exist"
                    exit 1
                  fi

                  QEMU_OPTS="$QEMU_OPTS -virtfs local,path=$USER_HOME,security_model=none,mount_tag=user_home"
                ''}

                run-nixos-vm
              '';
            in
            "${script} %i";
          ExecStopPost =
            let
              script = pkgs.writeScript "docker-vm-stop" ''
                #!${pkgs.runtimeShell}
                set -e

                USER="$1"
                USER_UID="$(id -u $USER)"

                META_DIR="/tmp/docker-vm/meta_$USER_UID"
                NIX_DISK_IMAGE="/tmp/docker-vm/storage_$USER_UID.qcow2"

                if [ -d $META_DIR ]; then
                  rm -r $META_DIR
                fi

                if [ -e $NIX_DISK_IMAGE ]; then
                  rm $NIX_DISK_IMAGE
                fi
              '';
            in
            "${script} %i";
        };
      };
    };
  };
}
