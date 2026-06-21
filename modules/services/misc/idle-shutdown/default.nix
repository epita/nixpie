{ config, lib, pkgs, ... }:

let
  cfg = config.cri.idle-shutdown;
in
{
  options = {
    cri.idle-shutdown = {
      enable = lib.mkEnableOption "idle shutdown";
      preventEndpoint = lib.mkOption {
        type = lib.types.str;
        default = "https://fleet.pie.cri.epita.fr/pxe/kvconfig/allow-idle-shutdown/";
        description = "Endpoint to check if idle shutdown is disabled.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.idle-shutdown = {
      description = "Poweroff computer when idling";
      environment = {
        "IDLE_PREVENT_ENDPOINT" = cfg.preventEndpoint;
      };
      path = with pkgs; [
        systemd
        curl
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash ${./idle-shutdown.sh}";
      };
    };

    systemd.timers.idle-shutdown = {
      description = "Check computer idle status on time";
      timerConfig = {
        Unit = "idle-shutdown.service";
        OnCalendar = "*-*-* *:*:00";
        RandomizedDelaySec = 40;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
