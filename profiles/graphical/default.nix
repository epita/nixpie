{ pkgs, config, lib, ... }:

with lib;
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
  };

  cri.programs.packages = with config.cri.programs.packageBundles; desktop;

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

  environment.etc."chromium/policies/recommended/spnego.json".text = builtins.toJSON {
    AuthServerWhitelist = "cri.epita.fr";
  };
}
