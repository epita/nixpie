{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.cri.nuc-led-setter;
  nuc-led-setter = inputs.nuc-led-setter.packages.${pkgs.system}.nuc-led-setter;
in
{
  options = {
    cri.nuc-led-setter = {
      enable = mkEnableOption "NUC led setter";
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ pkgs.intel_nuc_led ];

    systemd.services.nuc-led-setter = {
      description = "Read the current lock status and set the NUC's led accordingly";
      wantedBy = [ "multi-user.target" ];
      after = (optional config.cri.machine-state.enable "machine-state.service");
      path = [ pkgs.kmod ];

      preStart = ''
        modprobe nuc_led
      '';
      script = ''
        ${nuc-led-setter}/bin/nuc-led-setter
      '';
      postStop = ''
        ${nuc-led-setter}/bin/reset_led_on_poweroff.sh
      '';
    };
  };
}
