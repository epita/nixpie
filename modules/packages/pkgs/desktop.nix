{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.desktop.enable = lib.options.mkEnableOption "desktop CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.desktop.enable {
    environment.systemPackages = with pkgs; [
      # browsers
      chromium
      (if config.krb5.enable then
        (wrapFirefox firefox-unwrapped {
          extraPrefs = ''
            pref("network.negotiate-auth.trusted-uris", ".${lib.toLower config.krb5.libdefaults.default_realm}");
            pref("network.trr.excluded-domains", "${lib.toLower config.krb5.libdefaults.default_realm}");
          '';
        }) else firefox-unwrapped)

      # communication
      claws-mail
      irssi
      msmtp
      # Thunderbird 102 breaks NNTP, disabling the new JS implementation while
      # bug is opened: https://bugzilla.mozilla.org/show_bug.cgi?id=1787533
      (wrapThunderbird thunderbird-unwrapped {
        extraPrefs = ''
          pref("mailnews.nntp.jsmodule", false);
        '';
      })
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
