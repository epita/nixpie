{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.aria2 = {
      enable = mkEnableOption "Whether to enable aria2.";
      seedlist = mkOption {
        default = "${config.netboot.torrent.mountPoint}/aria2_seedlist.txt";
        description = "aria2 seedlist file to use for seeding torrent.";
      };
    };
  };

  config = mkIf config.cri.aria2.enable {
    users.groups.aria2.gid = config.ids.gids.aria2;
    users.users.aria2 = {
      description = "aria2 user";
      uid = config.ids.uids.aria2;
      group = "aria2";
    };

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
        User = "aria2";
      };

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
