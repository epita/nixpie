{ imageName, config, lib, pkgs, utils, ... }:

with lib;

let
  cfg = config.netboot;
  emergencyScript = pkgs.writeShellScript "forge-initrd-emergency" ''
    echo "This computer failed to boot, this might be a temporary failure or a hardware failure. You can try rebooting the machine by pressing CTRL+ALT+DEL. If the problem persists, please report this issue to Fleet Manager." | fold -s -w 74 | ${pkgs.boxes}/bin/boxes -d shell -p a1l2
    ${pkgs.qrencode}/bin/qrencode -t ANSI256UTF8 https://fleet.pie.cri.epita.fr
  '';
in
{
  options = {
    netboot = {
      enable = mkEnableOption "Set defaults for creating a netboot image";
      torrent = {
        mountPoint = mkOption {
          type = types.str;
          default = "/srv/torrent";
          description = "Mountpoint for the torrent files.";
        };
        announceURL = mkOption {
          type = types.str;
          default = "http://torrent.pie.cri.epita.fr:8000/announce";
          description = ''
            The torrent announce URL to use when creating the squashfs torrent.
          '';
        };
        webseed = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Add a webseed to the generated torrent.
            '';
          };
          url = mkOption {
            type = types.str;
            default = "https://s3.cri.epita.fr/cri-pxe-images.s3.cri.epita.fr/";
            description = "Webseed URL";
          };
        };
      };
      bootcache = {
        enable = mkEnableOption "bootcache partition mounting" // { default = true; };
        partition = mkOption {
          type = types.str;
          default = "/dev/disk/by-partlabel/bootcache";
          description = "Path to the bootcache partition to use.";
        };
      };
      fallbackNameservers = mkOption {
        type = types.listOf types.str;
        default = [ "1.1.1.1" ];
        description = "List of backup nameservers to use.";
      };
      home.enable = mkEnableOption "home partition mounting";
      swap.enable = mkEnableOption "swap partition mounting";
      nix-store-rw = {
        enable = mkEnableOption "Nix Store read-write partition mounting" // { default = true; };
        partition = mkOption {
          type = types.str;
          default = "/dev/disk/by-partlabel/nix-store-rw";
          description = "Path to the Nix store read/write partition to use.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Don't build the GRUB menu builder script, since we don't need it
    # here and it causes a cyclic dependency.
    boot.loader.grub.enable = false;

    fileSystems = {
      "/" = {
        fsType = "tmpfs";
        options = [ "mode=0755" "size=80%" ];
      };

      # In stage 1, mount a tmpfs on top of /nix/store (the squashfs
      # image) to make this a live CD.
      "/nix/.ro-store" = {
        fsType = "squashfs";
        device = "/sysroot/${cfg.torrent.mountPoint}/${imageName}.squashfs";
        options = [
          "loop"
          "threads=multi"
        ];
        neededForBoot = true;
      };

      "/nix/.rw-store" = mkIf cfg.nix-store-rw.enable {
        fsType = "ext4";
        device = cfg.nix-store-rw.partition;
        options = [
          "nofail"
          "x-systemd.device-timeout=15s"
        ];
        neededForBoot = true;
      };

      "/nix/store" = {
        overlay = {
          lowerdir = [ "/nix/.ro-store" ];
          upperdir = "/nix/.rw-store/store";
          workdir = "/nix/.rw-store/work";
        };
        neededForBoot = true;
      };

      "${cfg.torrent.mountPoint}" = mkIf cfg.bootcache.enable {
        fsType = "ext4";
        device = cfg.bootcache.partition;
        options = [ "nofail" "x-systemd.device-timeout=15s" ];
      };

      "/home" = mkIf cfg.home.enable {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/home";
        options = [ "nofail" "x-systemd.device-timeout=15s" ];
      };
    };
    swapDevices = mkIf config.netboot.swap.enable [{ label = "swap"; }];

    networking.useDHCP = mkForce true;

    boot.initrd = {
      availableKernelModules = [
        # To mount /nix/store
        "squashfs"
        "overlay"

        # SATA support
        "ahci"
        "ata_piix"
        "sata_inic162x"
        "sata_nv"
        "sata_promise"
        "sata_qstor"
        "sata_sil"
        "sata_sil24"
        "sata_sis"
        "sata_svw"
        "sata_sx4"
        "sata_uli"
        "sata_via"
        "sata_vsc"

        # NVMe
        "nvme"

        # Virtio (QEMU, KVM, etc.) support
        "virtio_pci"
        "virtio_blk"
        "virtio_scsi"
        "virtio_balloon"
        "virtio_console"
        "virtio_net"

        # Network support
        "ecb"
        "arc4"
        "bridge"
        "stp"
        "llc"
        "ipv6"
        "bonding"
        "8021q"
        "ipvlan"
        "macvlan"
        "af_packet"
        "xennet"
        "e1000e"
        "igc"
      ];
      kernelModules = [
        "loop"
        "overlay"
      ];

      network.enable = true;

      systemd = {
        network.enable = true;

        emergencyAccess = config.users.users.root.hashedPassword;
        initrdBin = with pkgs; [
          coreutils
          util-linux
          iproute2
          inetutils
          curl
        ];

        storePaths = with pkgs; [
          emergencyScript
          qrencode
          boxes
        ];

        services = {
          prepare-rw-nix-store =
            let
              partitionDeviceUnit = "${utils.escapeSystemdPath cfg.nix-store-rw.partition}.device";
            in
            {
              description = "Prepare read-write Nix store partition";
              requisite = [
                partitionDeviceUnit
              ];
              after = [
                partitionDeviceUnit
              ];
              before = [
                "sysroot-nix-.rw\\x2dstore.mount"
              ];
              requiredBy = [
                "initrd.target"
                "sysroot-nix-.rw\\x2dstore.mount"
              ];
              unitConfig = {
                AssertPathExists = cfg.nix-store-rw.partition;
                OnFailure = [ "emergency.target" ];
              };
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              path = with pkgs; [
                e2fsprogs
              ];
              script = ''
                nixStoreRwPartition="${cfg.nix-store-rw.partition}"
                if [[ -e $nixStoreRwPartition ]]; then
                  if ! ${pkgs.e2fsprogs}/bin/mkfs.ext4 -F -L nix-store-rw "$nixStoreRwPartition"; then
                    echo "Failed to cleanup nix-store-rw partition" >&2
                    exit 1
                  fi
                else
                  echo "No nix-store-rw partition found." >&2
                fi
              '';
            };

          rngd = {
            description = "Random number generator daemon";
            requiredBy = [ "initrd.target" ];
            serviceConfig = {
              ExecStart = [ "${pkgs.rng-tools}/bin/rngd" ];
            };
            path = with pkgs; [
              rng-tools
            ];
          };

          aria2-fetch-squashfs = {
            description = "Fetch Nix store squashfs with torrent";

            wants = [ "network-online.target" "rngd.service" ];
            after = [ "network-online.target" "rngd.service" ];
            before = [
              "initrd-find-nixos-closure.service"
              "sysroot-nix-.ro\\x2dstore.mount"
            ];
            requiredBy = [
              "initrd.target"
              "sysroot-nix-.ro\\x2dstore.mount"
            ];
            unitConfig = {
              OnFailure = [ "emergency.target" ];
            };
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };

            path = with pkgs; [
              coreutils
              gawk
              gnugrep
              gnused
              util-linux
              procps
              curl
              dumptorrent
              aria2
            ];

            script = ''
              imageName="${imageName}"
              torrentFile="$imageName.torrent"
              torrentFilePath="/${config.system.build.torrent.name}"
              squashfsName="$imageName.squashfs"

              torrentDir="/sysroot${config.netboot.torrent.mountPoint}"
              mkdir -p $torrentDir

              bootcachePartition="${config.netboot.bootcache.partition}"
              ${optionalString (!config.netboot.bootcache.enable) ''
                bootcachePartition="/dev/invalid"
              ''}

              if [[ -e $bootcachePartition ]]; then
                if ! mount -t ext4 $bootcachePartition $torrentDir; then
                  echo "Failed to mount bootcache, falling back to tmpfs..."
                  mount -t tmpfs tmpfs $torrentDir
                fi
              else
                echo "No bootcache partition found, falling back to tmpfs..."
                mount -t tmpfs tmpfs $torrentDir
              fi

              curl --fail --retry 5 --retry-max-time 120 --max-time 180 \
                -o "$torrentFilePath" "${config.netboot.torrent.webseed.url}$torrentFile"

              # Compute needed space to download squashfs in cache
              torrentSize=$(dumptorrent "$torrentFilePath" | grep Size | awk '{ print $2 }')
              downloadedImageSize=$(stat -c %s $torrentDir/$squashfsName 2>/dev/null || echo 0)
              neededSpace=$(((torrentSize - downloadedImageSize + 1000) / 1024))
              getAvailableCacheSpace() {
                  df -P "$torrentDir" | tail -n1 | awk '{ print $4 }'
              }
              availableCacheSpace=$(getAvailableCacheSpace)

              # Delete images until there is enough space to download our squashfs
              # Images are deleted starting from the oldest
              while [ "$availableCacheSpace" -lt "$neededSpace" ] && ls -l "$torrentDir" | grep -q 'squashfs$'; do
                oldestImage=$(stat -c "%Y %n" "$torrentDir"/*.squashfs | sort | head -1 | sed 's/[0-9]\+ //')
                oldestImageSize=$(stat -c "%s" "''${oldestImage%.*}".* | awk '{s+=$1} END {printf "%.0f", s}')
                echo "Deleting $oldestImage to free up $oldestImageSize bytes"
                rm -f  -- "''${oldestImage%.*}".*
                sync

                availableCacheSpace=$(getAvailableCacheSpace)
              done

              aria2_base="-V --file-allocation=prealloc --enable-mmap=true --bt-enable-lpd=true"
              aria2_tracker="--bt-tracker-connect-timeout=20 --bt-tracker-timeout=20"
              aria2_summary="--summary-interval=60"
              aria2_nodht="--enable-dht=false --enable-dht6=false"
              aria2_noseed="--seed-time=0 --seed-ratio=0"
              aria2_opts="$aria2_base $aria2_tracker $aria2_summary $aria2_nodht $aria2_noseed"

              cp "$torrentFilePath" $torrentDir/$torrentFile

              aria2c $aria2_opts --dir="$torrentDir" --index-out=1="$squashfsName" $torrentDir/$torrentFile > /dev/console

              if ! [ -f "$torrentDir/$squashfsName" ]; then
                ls -la "$torrentDir"
                echo "Torrent download of '$squashfsName' failed!"
                exit 1
              fi
            '';
          };

          # Taken from nixos/modules/system/boot/systemd/initrd.nix
          # Edited to look for closure path in the stage2Init file in squashfs
          # instead of using init= kernel parameter
          initrd-find-nixos-closure = {
            script = # bash
              lib.mkForce ''
                set -uo pipefail
                export PATH="/bin:${
                  lib.makeBinPath [
                    config.boot.initrd.systemd.package.util-linux
                    config.system.nixos-init.package
                  ]
                }"

                closure=$(cat /sysroot/nix/store/stage2Init)

                # Sanity check
                if [ -z "''${closure:-}" ]; then
                  echo 'No init closure found in squashfs' >&2
                  exit 1
                fi

                # Resolve symlinks in the init parameter. We need this for some boot loaders
                # (e.g. boot.loader.generationsDir).
                closure="$(resolve-in-root /sysroot "$closure")"

                # Assume the directory containing the init script is the closure.
                closure="$(dirname "$closure")"

                ln --symbolic "$closure" /nixos-closure

                echo 'NEW_INIT=' > /etc/switch-root.conf
              '';
          };

          emergency.serviceConfig = {
            ExecStartPre = [
              emergencyScript
            ];
          };

          # During switch-root, systemd stops every unit except the ones with
          # IgnoreOnIsolate but for some reasons systemd-modules-load survives
          # that and is never restarted after switch-root. That's not the
          # behaviour we want because we might need to load other modules (from
          # boot.kernelModules) after initrd.
          # A proper fix would be to find the unit relationship that blocks
          # systemd-modules-load from deactivating before switch root (likely to
          # be something with the above units). But this works for now, and is
          # also a workaround used by systemd themselves for systemd-networkd
          # and systemd-resolved.
          systemd-modules-load = {
            before = [ "initrd-switch-root.target" ];
            conflicts = [ "initrd-switch-root.target" ];
          };
        };
      };
    };

    # Taken from nixpkgs: nixos/modules/installer/netboot/netboot.nix
    systemd.services.register-nix-paths = {
      description = "Register Nix Store Paths";
      unitConfig.DefaultDependencies = false;
      wantedBy = [ "sysinit.target" ];
      before = [
        "sysinit.target"
        "shutdown.target"
        "nix-daemon.socket"
        "nix-daemon.service"
      ];
      after = [ "local-fs.target" ];
      conflicts = [ "shutdown.target" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # After booting, register the contents of the Nix store
        # in the Nix database in the tmpfs.
        ${lib.getExe' config.nix.package "nix-store"} --load-db < /nix/store/nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${lib.getExe' config.nix.package "nix-env"} -p /nix/var/nix/profiles/system --set /run/current-system
      '';
    };

    ###
    ### Outputs from the configuration needed to boot.
    ###

    # Create the squashfs image that contains the Nix store.
    system.build.squashfs = pkgs.callPackage ../../../lib/make-squashfs.nix {
      name = "${imageName}.squashfs";
      storeContents = singleton config.system.build.toplevel;
      stage2Init = "${config.system.build.toplevel}/init";
    };

    # Torrent file to download the squashfs
    system.build.torrent = pkgs.stdenv.mkDerivation {
      name = "${imageName}.torrent";
      src = config.system.build.squashfs;
      nativeBuildInputs = [ pkgs.mktorrent ];

      buildCommand = ''
        mktorrent --no-date \
          --announce="${config.netboot.torrent.announceURL}" \
          --output="$out" \
          ${if config.netboot.torrent.webseed.enable then ''--web-seed="${config.netboot.torrent.webseed.url}"'' else ""} \
          $src/${config.system.build.squashfs.name}
      '';
    };

    # Include the torrent in the image to download the squashfs.
    #boot.initrd.systemd.contents."/${config.system.build.torrent.name}".source = config.system.build.torrent;
    # Required by aria2.
    boot.initrd.systemd.contents."/etc/ssl/certs/ca-certificates.crt".source = config.environment.etc."ssl/certs/ca-certificates.crt".source;

    system.build.toplevel-netboot = pkgs.runCommand "${imageName}.toplevel-netboot" { } ''
      mkdir -p $out
      cp ${config.system.build.kernel}/bzImage $out/${imageName}_bzImage
      cp ${config.system.build.initialRamdisk}/initrd $out/${imageName}_initrd
      cp ${config.system.build.torrent} $out/${imageName}.torrent
      cp ${config.system.build.squashfs}/${config.system.build.squashfs.name} $out/${imageName}.squashfs

      echo "${config.system.nixos.label}" > $out/${imageName}.version

      sha256sum $out/${imageName}_bzImage > $out/${imageName}_bzImage.sha256sum
      sha256sum $out/${imageName}_initrd > $out/${imageName}_initrd.sha256sum
      sha256sum $out/${imageName}.torrent > $out/${imageName}.torrent.sha256sum
      sha256sum $out/${imageName}.squashfs > $out/${imageName}.squashfs.sha256sum
    '';
  };
}
