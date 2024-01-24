{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.libvirt = {
      enable = lib.options.mkEnableOption "libvirt Forge package bundle";
      enableDiskPartition = lib.options.mkEnableOption "work partition for libvirt";
    };
  };

  config = lib.mkIf config.cri.packages.pkgs.libvirt.enable (lib.mkMerge [
    {
      virtualisation.libvirtd = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        virt-manager
      ];

      systemd.services.libvirtd-config.script = lib.mkAfter ''
        mkdir -p /var/lib/libvirt/qemu/networks/autostart
        ln -s /var/lib/libvirt/qemu/networks/default.xml /var/lib/libvirt/qemu/networks/autostart/
      '';
    }
    (lib.mkIf config.cri.packages.pkgs.libvirt.enableDiskPartition {
      systemd.services.forge-libvirt-disk-setup = {
        description = "Forge libvirt work partition setup";
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [ gptfdisk e2fsprogs util-linux coreutils-full ];
        script = ''
          set -euo pipefail

          if [ ! -f /dev/disk/by-partlabel/libvirt-workdir ]; then

            echo "Scanning disks on the system:"
            disks="$(lsblk --list --noheadings --paths --output NAME,SIZE,TYPE | grep ' disk')"

            if [ -z "$disks" ]; then
              echo "Error: no disk found!"
              exit 1
            fi

            DISK_NAME="/dev/invalid"
            if [ "$(echo "$disks" | wc -l)" -ne 1 ]; then
              echo "Multiple disks found. Exiting"
              exit 1
            else
              DISK_NAME="$(echo "$disks" | cut -d" " -f1)"
            fi

            sgdisk --new 3:0:+32G "$DISK_NAME"
            sgdisk --change-name 3:libvirt-workdir "$DISK_NAME"

            partx --update "$DISK_NAME"

            sleep 5
          fi

          mkfs.ext4 -F -L libvirt-workdir /dev/disk/by-partlabel/libvirt-workdir

          mkdir -p /srv/libvirt-workdir
          mount /dev/disk/by-partlabel/libvirt-workdir /srv/libvirt-workdir
          chmod -R 777 /srv/libvirt-workdir
        '';

        serviceConfig = {
          Type = "oneshot";
        };
      };
    })
  ]);
}
