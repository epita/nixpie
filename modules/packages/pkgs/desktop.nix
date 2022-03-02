{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.desktop.enable = lib.options.mkEnableOption "desktop CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.desktop.enable {
    environment.systemPackages = with pkgs; [
      # browsers
      chromium
      (wrapFirefox firefox-unwrapped {
        extraPrefs = ''
          pref("network.negotiate-auth.trusted-uris", "cri.epita.fr,.cri.epita.fr");
        '';
      })

      # communication
      claws-mail
      irssi
      msmtp
      thunderbird
      weechat

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
      bc
      dialog
      gnome3.zenity
      hicolor-icon-theme
      keepassxc
      mlocate
      netcat-gnu
      rlwrap
      rxvt-unicode
      xorg.xeyes
      xorg.xinit
      xorg.xkill
      xsel
      xterm

      # pdf reader
      evince
      zathura

      # video tools
      vlc

      # back to home
      discord
      slack
      teams
    ];
  };
}