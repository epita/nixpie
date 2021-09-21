{ imageName, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.cri.node-exporter;
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
      extraFlags = [
        "--collector.textfile.directory=/etc/prometheus-node-exporter-textfile"
      ];
    };

    environment.etc."prometheus-node-exporter-textfile/nixpie.prom".text =
      let
        versions = concatStringsSep ", " (mapAttrsToList (flake: version: ''${flake}="${version}"'') config.system.nixos.versions);
      in
      ''
        nixpie_image{image="${imageName}", ${versions}} 1
      '';
  };
}
