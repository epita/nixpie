{ config, lib, ... }:

with lib;

{
  options = {
    cri.xfce = {
      enable = mkEnableOption "Enable xfce";
    };
  };

  config = mkIf config.cri.xfce.enable {
    services.xserver.desktopManager.xfce = {
      enable = true;
    };
  };
}
