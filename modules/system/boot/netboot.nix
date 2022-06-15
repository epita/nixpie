{ imageName, config, lib, pkgs, ... }:

with lib;

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
        default = [ "10.224.21.53" "1.1.1.1" ];
        description = "List of backup nameservers to use.";
      };
      home.enable = mkEnableOption "home partition mounting";
      swap.enable = mkEnableOption "swap partition mounting";
      nix-store-rw.enable = mkEnableOption "Nix Store read-write partition mounting" // { default = true; };
    };
  };

  config = mkIf config.netboot.enable {
    # Don't build the GRUB menu builder script, since we don't need it
    # here and it causes a cyclic dependency.
    boot.loader.grub.enable = false;

    # !!! Hack - attributes expected by other modules.
    environment.systemPackages = [ pkgs.grub2_efi pkgs.grub2 pkgs.syslinux ];

    fileSystems = {
      "/" = {
        fsType = "tmpfs";
        options = [ "mode=0755" "size=80%" ];
      };

      # In stage 1, mount a tmpfs on top of /nix/store (the squashfs
      # image) to make this a live CD.
      "/nix/.ro-store" = {
        fsType = "squashfs";
        device = "../${config.netboot.torrent.mountPoint}/${imageName}.squashfs";
        options = [ "loop" ];
        neededForBoot = true;
      };

      "/nix/.rw-store" = mkIf config.netboot.nix-store-rw.enable {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/nix-store-rw";
        options = [ "nofail" "x-systemd.device-timeout=15s" ];
        neededForBoot = true;
      };

      "/nix/store" = {
        fsType = "overlay";
        device = "overlay";
        options = [
          "lowerdir=/nix/.ro-store"
          "upperdir=/nix/.rw-store/store"
          "workdir=/nix/.rw-store/work"
        ];
      };

      "${config.netboot.torrent.mountPoint}" = mkIf config.netboot.bootcache.enable {
        fsType = "ext4";
        device = config.netboot.bootcache.partition;
        options = [ "nofail" "x-systemd.device-timeout=15s" ];
      };

      "/home" = mkIf config.netboot.home.enable {
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
      ];
      kernelModules = [
        "loop"
        "overlay"
      ];

      # For torrent downloading
      network.enable = true;
      network.udhcpc.extraArgs = [ "-t 10" "-A 10" ];
      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.aria2}/bin/aria2c
        copy_bin_and_libs ${pkgs.dumptorrent}/bin/dumptorrent
        copy_bin_and_libs ${pkgs.rng-tools}/bin/rngd
        copy_bin_and_libs ${pkgs.e2fsprogs}/bin/mke2fs
        copy_bin_and_libs ${pkgs.e2fsprogs}/bin/mkfs.ext4
      '';
    };

    ###
    ### Commands to execute on boot to download the system and configure it
    ### properly.
    ###

    # Network is done in preLVMCommands, which means it is already set up when
    # we get to postDeviceCommands
    boot.initrd.postDeviceCommands =
      let
        nameservers = (concatMapStrings
          (ns: ''echo "${ns}" >> /etc/resolv.conf\n'')
          config.netboot.fallbackNameservers);
      in
      ''
        if ! [ -f /etc/resolv.conf ]; then
          # In case we didn't receive a nameserver from our DHCP
          ${nameservers}
        fi

        nixStoreRwPartition="/dev/disk/by-partlabel/nix-store-rw"
        if [[ -e $nixStoreRwPartition ]]; then
          if ! mkfs.ext4 -F -L nix-store-rw /dev/disk/by-partlabel/nix-store-rw; then
            echo "Failed to cleanup nix-store-rw partition"
          fi
        else
          echo "No nix-store-rw partition found."
        fi

        imageName="${imageName}"
        torrentFile="$imageName.torrent"
        torrentFilePath="/${config.system.build.torrent.name}"
        squashfsName="$imageName.squashfs"

        torrentDir=${config.netboot.torrent.mountPoint}
        targetTorrentDir=$targetRoot/$torrentDir
        mkdir -p $torrentDir $targetRoot $targetTorrentDir

        mount -o bind,ro $torrentDir $targetTorrentDir

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

        rngd >&2

        aria2_base="-V --file-allocation=prealloc --enable-mmap=true --bt-enable-lpd=true"
        aria2_tracker="--bt-tracker-connect-timeout=20 --bt-tracker-timeout=20"
        aria2_summary="--summary-interval=60"
        aria2_nodht="--enable-dht=false --enable-dht6=false"
        aria2_noseed="--seed-time=0 --seed-ratio=0"
        aria2_opts="$aria2_base $aria2_tracker $aria2_summary $aria2_nodht $aria2_noseed"

        cp "$torrentFilePath" $torrentDir/$torrentFile

        aria2c $aria2_opts --dir="$torrentDir" --index-out=1="$squashfsName" $torrentDir/$torrentFile > /dev/console

        if ! [ -f "$torrentDir/$squashfsName" ]; then
          ls -la $torrentDir
          echo "Torrent download of '$squashfsName' failed!"
          fail
        fi

        kill -9 $(pidof rngd)

        for torrent in $(ls $torrentDir/*.torrent); do
          torrentname=''${torrent##*/}
          echo $torrent
          echo " index-out=1=''${torrentname%.torrent}.squashfs"
          echo " dir=$torrentDir"
          echo " check-integrity=true"
        done > "$torrentDir/aria2_seedlist.txt"
      '';

    # Usually, stage2Init is passed using the init kernel command line argument
    # but it would be inconvenient to manually change it to the right Nix store
    # path every time we rebuild an image. We just set it here and forget about
    # it.
    # Also, we cannot directly reference the current system.build.toplevel, as
    # it would cause an infinite recursion, so we have to put it in another
    # system.build artefact, in this case our squashfs, and use it from
    # there
    boot.initrd.postMountCommands = ''
      export stage2Init=$(cat $targetRoot/nix/store/stage2Init)
    '';

    boot.postBootCommands = ''
      # After booting, register the contents of the Nix store
      # in the Nix database in the tmpfs.
      ${config.nix.package}/bin/nix-store --load-db < /nix/store/nix-path-registration

      # nixos-rebuild also requires a "system" profile and an
      # /etc/NIXOS tag.
      touch /etc/NIXOS
      ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
    '';

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

    # Using the prepend argument here for system.build.initialRamdisk doesn't
    # work, so we just create an extra initrd and concatenate the two later.
    system.build.extraInitrd = pkgs.makeInitrd {
      name = "extraInitrd";
      inherit (config.boot.initrd) compressor;

      contents = [
        {
          # Include the torrent in the image to download the squashfs.
          object = config.system.build.torrent;
          symlink = "/${config.system.build.torrent.name}";
        }
        {
          # Required by aria2.
          object =
            config.environment.etc."ssl/certs/ca-certificates.crt".source;
          symlink = "/etc/ssl/certs/ca-certificates.crt";
        }
      ];
    };

    # Concatenate the required initrds.
    system.build.initrd = pkgs.runCommand "initrd" { } ''
      cat \
        ${config.system.build.initialRamdisk}/initrd \
        ${config.system.build.extraInitrd}/initrd \
        > $out
    '';

    system.build.toplevel-netboot = pkgs.runCommand "${imageName}.toplevel-netboot" { } ''
      mkdir -p $out
      cp ${config.system.build.kernel}/bzImage $out/${imageName}_bzImage
      cp ${config.system.build.initrd} $out/${imageName}_initrd
      cp ${config.system.build.torrent} $out/${imageName}.torrent
      cp ${config.system.build.squashfs}/${config.system.build.squashfs.name} $out/${imageName}.squashfs
    '';
  };
}
