{ config, lib, pkgs, ... }:

let
  cfg = config.cri.sm-inventory-agent;
in
{
  options = {
    cri.sm-inventory-agent = {
      enable = lib.mkEnableOption "SM inventory agent";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sm-inventory-agent = {
      description = "Push SM inventory info";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = with pkgs; [
        coreutils
        gnused
        gnugrep
        inetutils
        dmidecode
        read-edid
        curl
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash ${./push-sm-inventory.sh}";
        Restart = "on-failure";
        RestartSec = "10";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
