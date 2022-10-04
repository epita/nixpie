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
        aria2_base="-V --file-allocation=prealloc --enable-mmap=true --bt-enable-lpd=true"
        aria2_summary="--summary-interval=60"
        aria2_nodht="--enable-dht=false --enable-dht6=false"
        aria2_always_seed="--seed-ratio=0"
        aria2_opts="$aria2_base $aria2_summary $aria2_nodht $aria2_always_seed"

        ${pkgs.aria2}/bin/aria2c $aria2_opts --check-integrity --input-file=${config.cri.aria2.seedlist}
      '';
    };

    systemd.services.pieupdate = {
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        shopt -s nullglob

        torrentDir=${config.netboot.torrent.mountPoint}

        for torrent in $torrentDir/*.torrent; do
          oldChksum=$(sha1sum "$torrent")
          torrentFile=$(basename "$torrent")
          echo "Fetching $torrentFile"
          ${pkgs.curl}/bin/curl "${config.netboot.torrent.webseed.url}/$torrentFile" \
            -o "$torrentFile"
          newChksum=$(sha1sum "$torrent")

          if [ "$oldChksum" != "$newChksum" ]; then
            echo "Detected a change"
            restart=1
          fi
        done

        if [ -n restart ]; then
          echo "Restarting aria2"
          ${pkgs.systemd}/bin/systemctl restart aria2
        fi
      '';
    };

    systemd.timers.pieupdate = {
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      timerConfig = {
        Unit = "pieupdate.service";
        OnCalendar = "*-*-* *:00:00";
        RandomizedDelaySec = "60";
      };
    };
  };
}
