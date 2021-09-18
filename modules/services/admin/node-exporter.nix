{ lib, ... }:

with lib;

let
  cfg = cfg.cri.node-exporter;
in
{
  options = {
    cri.node-exporter = {
      enable = mkEnableOption "node-exporter";
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
  };
}
