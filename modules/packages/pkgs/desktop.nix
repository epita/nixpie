{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.cri.packages.pkgs.desktop;
in
{
  options = {
    cri.packages.pkgs.desktop = {
      enable = mkEnableOption "desktop CRI package bundle";
      firefox = {
        toolbarBookmarks = mkOption {
          default = [ ];
          type = with types; listOf (attrsOf str);
          description = "List of Firefox bookmarks to add in toolbar";
          example = [
            {
              Title = "Forge ID";
              URL = "https://cri.epita.fr";
              Favicon = "https://s3.cri.epita.fr/cri-intranet/img/logo.png";
            }
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      # browsers
      chromium
      (wrapFirefox firefox-unwrapped {
        extraPrefs = ''
          pref("network.negotiate-auth.trusted-uris", "cri.epita.fr,.cri.epita.fr");
          pref("network.trr.excluded-domains", "cri.epita.fr");
        '';
        extraPolicies = optionalAttrs (builtins.length cfg.firefox.toolbarBookmarks > 0) {
          Bookmarks = builtins.map (bookmark: bookmark // { Placement = "toolbar"; }) cfg.firefox.toolbarBookmarks;
          DisplayBookmarksToolbar = "always";
        };
      })

      # communication
      thunderbird

      # editors
      (emacs.pkgs.withPackages (epkgs: (with epkgs.melpaStablePackages; [
        tuareg
      ])))

      # images
      feh
      gimp
      imagemagick
      scrot

      # misc
      alacritty
      bc
      dialog
      zenity
      hicolor-icon-theme
      keepassxc
      mlocate
      netcat-openbsd
      rlwrap
      rxvt-unicode
      xorg.xeyes
      xorg.xinit
      xorg.xkill
      xsel
      xterm
      x11vnc

      # pdf reader
      evince
      zathura

      # video tools
      vlc

      # back to home
      discord
    ];
  };
}
