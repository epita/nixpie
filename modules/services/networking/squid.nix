{ config, pkgs, lib, ... }:

with lib;

let
  proxypac = pkgs.writeTextDir "wpad.dat" ''
    function FindProxyForURL (url, host) {
      return 'PROXY localhost:3128; DIRECT';
    }
  '';
  squidConfigPath = "/var/run/squid.conf";
in
{
  options = {
    cri.squid = {
      enable = mkEnableOption "Whether to enable squid";
      configEndpoint = mkOption {
        type = types.str;
        default = "https://s3.cri.epita.fr/cri-fleet-manager/squid.conf";
        description = "squid dynamic config endpoint";
      };
    };
  };

  config = mkIf config.cri.squid.enable {
    services.squid.enable = true;

    systemd.services.squid = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      preStart = lib.mkForce ''
        ${pkgs.curl}/bin/curl --fail -o /var/run/squid.conf "${config.cri.squid.configEndpoint}"
        mkdir -p "/var/log/squid"
        chown squid:squid "/var/log/squid"
        ${config.services.squid.package}/bin/squid --foreground -z -f ${squidConfigPath}
      '';
      serviceConfig = {
        ExecStart = lib.mkForce "${config.services.squid.package}/bin/squid --foreground -YCs -f ${squidConfigPath}";
        Restart = "on-failure";
      };
    };

    networking.proxy = {
      httpProxy = "http://127.0.0.1:3128";
      httpsProxy = "http://127.0.0.1:3128";
    };

    networking.hosts = {
      "127.0.0.1" = [ "wpad" ];
    };

    services.lighttpd = {
      enable = true;
      document-root = proxypac;
    };
  };
}
