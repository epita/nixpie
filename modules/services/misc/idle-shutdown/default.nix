{ config, lib, pkgs, ... }:

let
  cfg = config.cri.idle-shutdown;
in
{
  options = {
    cri.idle-shutdown = {
      enable = lib.mkEnableOption "idle shutdown";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.idle-shutdown = {
      description = "Poweroff computer when idling";
      path = with pkgs; [ nixpie-utils iputils ];
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
