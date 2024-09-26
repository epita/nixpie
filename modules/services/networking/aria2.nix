{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.aria2 = {
      enable = mkEnableOption "Whether to enable aria2.";
      torrentDir = mkOption {
        default = "${config.netboot.torrent.mountPoint}";
        description = "path to seeded torrents";
      };
      seedlist = mkOption {
        default = "${config.netboot.torrent.mountPoint}/aria2_seedlist.txt";
        description = "aria2 seedlist file to use for seeding torrent.";
      };
    };
  };

  config = mkIf config.cri.aria2.enable {
    networking.firewall = {
      allowedTCPPortRanges = [{ from = 6881; to = 6999; }];
      allowedUDPPortRanges = [{ from = 6881; to = 6999; }];
    };

    systemd.services.aria2 = {
      description = "aria2";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
      };

      preStart = ''
        for torrent in $(ls ${config.cri.aria2.torrentDir}/*.torrent); do
          torrentname=''${torrent##*/}
          echo $torrent
          echo " index-out=1=''${torrentname%.torrent}.squashfs"
          echo " dir=${config.cri.aria2.torrentDir}"
          echo " check-integrity=true"
        done > "${config.cri.aria2.seedlist}"
      '';

      script = ''
        aria2_base="-V --file-allocation=prealloc --enable-mmap=true --bt-enable-lpd=true"
        aria2_summary="--summary-interval=60"
        aria2_nodht="--enable-dht=false --enable-dht6=false"
        aria2_always_seed="--seed-ratio=0"
        aria2_opts="$aria2_base $aria2_summary $aria2_nodht $aria2_always_seed"

        ${pkgs.aria2}/bin/aria2c $aria2_opts --check-integrity --input-file=${config.cri.aria2.seedlist}
      '';
    };
  };
}
