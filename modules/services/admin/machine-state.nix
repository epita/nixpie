{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.cri.machine-state;
  machine-state = inputs.machine-state.packages.${pkgs.system}.machine-state;
in
{
  options = {
    cri.machine-state = {
      enable = mkEnableOption "machine state";
    };
  };

  config = mkIf cfg.enable {
    services.dbus.packages = [ machine-state ];

    systemd.services.machine-state = {
      description = "DBus object representing current machine state";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = with pkgs; [ coreutils gnugrep gawk gnused iproute ];

      environment = {
        MACHINE_STATE_ENDPOINT = "https://machine-state.pie.cri.epita.fr/session/ping";
      };

      preStart = ''
        while true; do
          ip="$(ip a | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | sed 's#/.*$##')"
          if [ -n "$ip" ] ; then
            break
          fi
          sleep 2
        done
      '';

      script = ''
        export MACHINE_STATE_IP="$(ip a | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | sed 's#/.*$##')"
        ${machine-state}/bin/machine-state
      '';
    };
  };
}
