{ pkgs, ... }:

{
  cri.programs.desktop = with pkgs; [
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
  ];
}
