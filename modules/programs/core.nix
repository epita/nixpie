{ pkgs, ... }:

{
  cri.programs.core = with pkgs; [
    git
    htop
    iproute
    lsof
    man-pages
    man-pages-posix
    pipenv
    psmisc
    python3
    python3Packages.pip
    python3Packages.virtualenv
    rsync
    screen
    tcpdump
    termSize
    tmux
    tree
    udevil
    unzip
    wget
    zip
  ];
}
