{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.i3 = {
      enable = mkEnableOption "Enable i3";
    };
  };

  config = mkIf config.cri.i3.enable {
    services.xserver.windowManager.i3 = {
      enable = true;
      extraSessionCommands = ''
        ${pkgs.feh}/bin/feh --bg-scale ${../files/background.jpg}
      '';
    };
  };
}
