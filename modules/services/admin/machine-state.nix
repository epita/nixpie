{ imageName, config, pkgs, lib, inputs, ... }:

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

      serviceConfig = {
        Restart = "always";
      };

      environment = {
        MACHINE_STATE_SESSION_ENDPOINT = "https://fleet.pie.cri.epita.fr/api/sessions/ping";
        MACHINE_STATE_ISSUES_ENDPOINT = "https://fleet.pie.cri.epita.fr/api/fleet/issues/";
        IMAGE = imageName;
      };

      preStart = ''
        # We're just waiting for an IP to appear, we don't actually care about
        # it here
        ${pkgs.nixpie-utils}/bin/get_ip.sh
      '';

      script = ''
        export MACHINE_STATE_IP="$(${pkgs.nixpie-utils}/bin/get_ip.sh)"
        ${machine-state}/bin/machine-state
      '';
    };
  };
}
