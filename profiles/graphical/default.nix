{ pkgs, config, lib, ... }:

let
  Xresources = pkgs.writeText "Xresources" ''
    *.scrollBar       : false
    *metaSendsEscape  : true
    *sessionMgt       : false
    *utf8             : always
    ! colors
    *.foreground      : white
    *.background      : black
    ! make dark blue color more readable
    *.color12         : #2ca2f5

    URxvt.font        : xft:DejaVu Sans Mono:pixelsize=10:antialias=true:hinting=true
  '';
in
{
  cri = {
    bluetooth.enable = true;
    i3.enable = true;
    redshift.enable = true;
    sddm.enable = true;
    sound.enable = true;
    idle-shutdown.enable = true;
  };

  cri.packages.pkgs.desktop.enable = true;

  services.xserver = {
    enable = true;
    autorun = true;

    videoDrivers = [ "radeon" "cirrus" "vesa" "vmware" "modesetting" "intel" ];

    layout = "us,fr,gb";
    displayManager = {
      setupCommands = ''
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap us,fr,gb
      '';

      sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge ${Xresources}
      '';
    };
  };

  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/mailto" = "thunderbird.desktop";
    "text/html" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
    ];
    fontconfig = {
      enable = true;
      hinting.enable = true;
    };
  };

  environment.etc."chromium/policies/recommended/spnego.json".text = lib.mkIf config.krb5.enable (builtins.toJSON {
    AuthServerWhitelist = lib.toLower config.krb5.libdefaults.default_realm;
    AuthServerAllowlist = lib.toLower config.krb5.libdefaults.default_realm;
  });
}
