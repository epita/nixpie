{ config, pkgs, lib, ... }:

with lib;

let
  sddm-epita-simplyflat = pkgs.sddm-epita-simplyflat.override {
    extraThemeConfig = ''
      logo=epita.png
      title="-- ${config.cri.sddm.title} --"
      footer="nixos-system-${config.system.name}-${config.system.nixos.label}"
    '';
  };
in
{
  options = {
    cri.sddm = {
      enable = mkEnableOption "Enable sddm";
      title = mkOption {
        type = types.str;
        default = "EPITA";
        description = "SDDM title";
      };
      autoLogin = {
        enable = mkEnableOption "Autologin with configured user.";
        user = mkOption {
          type = types.str;
          default = "epita";
          description = "User to use for autologin";
        };
      };
    };
  };

  config = mkIf config.cri.sddm.enable {
    services.xserver.displayManager = {
      autoLogin = {
        inherit (config.cri.sddm.autoLogin) enable user;
      };
      sddm = {
        enable = true;
        autoNumlock = true;
        autoLogin.relogin = true;
        theme = "epita-simplyflat";
        settings.Theme.ThemeDir = "${sddm-epita-simplyflat}/share/sddm/themes";
      };
    };

    systemd.services.display-manager = {
      after = [ "network-online.target" ];
    };
  };
}
