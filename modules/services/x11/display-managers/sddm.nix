{ config, pkgs, lib, ... }:

with lib;

let
  sddmExtraThemeConfig = ''
    [General]
    logo=epita.png
    title="-- ${config.cri.sddm.title} --"
    footer="nixos-system-${config.system.name}-${config.system.nixos.label}"
  '';

  sddmThemeConfigOverride = pkgs.writeTextDir "share/sddm/themes/${config.cri.sddm.theme}/theme.conf.user" sddmExtraThemeConfig;
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
      theme = mkOption {
        type = types.str;
        default = "epita-simplyblack";
        description = "SDDM theme";
      };
    };
  };

  config = mkIf config.cri.sddm.enable {
    services.displayManager = {
      autoLogin = {
        inherit (config.cri.sddm.autoLogin) enable user;
      };
      sddm = {
        inherit (config.cri.sddm) theme;
        enable = true;
        autoNumlock = true;
        autoLogin.relogin = true;
        package = pkgs.sddm;
      };
    };

    environment.systemPackages = with pkgs; [ sddm-epita-themes ] ++
      optionals (hasPrefix "epita-" config.cri.sddm.theme) [ sddmThemeConfigOverride ];

    systemd.services.display-manager = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
