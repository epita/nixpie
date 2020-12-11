{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.cri.packages;
  contains = list: elem: any (e: e == elem) list;
in
{
  options = {
    cri.packages = mkOption {
      default = [ ];
      type = with types; listOf (enum [
        "core"
        "fuse"
        "desktop"
      ]);
      description = "List of types of packages to install";
    };
  };

  config = {
    environment.systemPackages = with pkgs; flatten [
      (optionals (contains cfg "core") [
        git
        htop
        iproute
        lsof
        psmisc
        python3
        python3Packages.pip
        pipenv
        python3Packages.virtualenv
        rsync
        screen
        tcpdump
        term_size
        tmux
        tree
        udevil
        unzip
        wget
        zip
      ])

      (optionals (contains cfg "core") [
        fuse
        fuse3
        fuseiso
        sshfs
      ])

      (optionals (contains cfg "desktop") [
        # browsers
        chromium
        firefox

        # communication
        claws-mail
        irssi
        msmtp
        thunderbird
        weechat

        # editors
        emacs

        # images
        feh
        gimp
        imagemagick
        scrot

        # misc
        bc
        dialog
        gnome3.zenity
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
      ])
    ];
  };
}
