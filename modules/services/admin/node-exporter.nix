{ imageName, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.cri.node-exporter;
in
{
  options = {
    cri.node-exporter = {
      enable = mkEnableOption "node-exporter";
      pushGateway = {
        enable = mkEnableOption "push gateway" // { default = true; };
        address = mkOption {
          default = "https://pushgateway.pie.cri.epita.fr";
          type = types.str;
        };
        interval = mkOption {
          default = "*:*:0/30";
          type = types.str;
          description = ''
            Systemd calendar expression when to push metrics. See
            <citerefentry><refentrytitle>systemd.time</refentrytitle>
            <manvolnum>7</manvolnum></citerefentry>.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };

    systemd.services.node-exporter-pushgateway = mkIf cfg.pushGateway.enable {
      description = "Push node-exporter metrics to Prometheus PushGateway";
      requires = [ "network-online.target" ];

      path = with pkgs; [ coreutils curl gnugrep gnused gawk gnused iproute ];

      preStart = ''
        while true; do
          ip="$(ip a | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | sed 's#/.*$##')"
          if [ -n "$ip" ] ; then
            break
          fi
          sleep 2
        done
      '';

      # grep allows us to avoid conflicting with the pushgateway's own metrics
      script =
        let
          versions = concatStringsSep ", " (mapAttrsToList (flake: version: ''${flake}="${version}"'') config.system.nixos.versions);
        in
        ''
          ip="$(ip a | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | sed 's#/.*$##')"

          curl -s http://localhost:9100/metrics | \
            grep -v "\(\(^\| \)go_\|http_request\|http_requests\|http_response\|process_\)" | \
            sed 's/^node_/pie_node_/g' | \
            curl -s --data-binary @- "${cfg.pushGateway.address}/metrics/job/pie_node/instance/''${ip}"

          echo 'nixpie_image{image="${imageName}", ${versions}} 1' | \
            curl -s --data-binary @- "${cfg.pushGateway.address}/metrics/job/image/instance/''${ip}"
        '';
    };

    systemd.timers.node-exporter-pushgateway = mkIf cfg.pushGateway.enable {
      description = "Push node-exporter metrics to Prometheus PushGateway";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.pushGateway.interval;
        AccuracySec = "30";
        RandomizedDelaySec = "30";
        FixedRandomDelay = true;
        Unit = "node-exporter-pushgateway.service";
        Persistent = "yes";
      };
    };
  };
}
