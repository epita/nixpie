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
          default = "http://seedbox.pie.cri.epita.fr:9091";
          type = types.str;
        };
        interval = mkOption {
          default = "30s";
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

      path = with pkgs; [ curl gnugrep inetutils ];

      # grep allows us to avoid conflicting with the pushgateway's own metrics
      script = ''
        curl -s http://localhost:9100/metrics | \
        grep -v "\(\(^\| \)go_\|http_request\|http_requests\|http_response\|process_\)" | \
        curl --data-binary @- "${cfg.pushGateway.address}/metrics/job/node/instance/$(hostname -f)"

        echo "${imageName}" | curl --data-binary @- "${cfg.pushGateway.address}/metrics/job/image/instance/$(hostname -f)"
      '';
    };

    systemd.timers.node-exporter-pushgateway = mkIf cfg.pushGateway.enable {
      description = "Push node-exporter metrics to Prometheus PushGateway";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.pushGateway.interval;
        Unit = "node-exporter-pushgateway.service";
        Persistent = "yes";
      };
    };
  };
}
