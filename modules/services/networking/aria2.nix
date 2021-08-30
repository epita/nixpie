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

      script = ''
        ${pkgs.aria2}/bin/aria2c --enable-dht=false --seed-ratio=0 -V -i ${config.cri.aria2.seedlist}
      '';
    };
  };
}
