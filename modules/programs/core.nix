{ pkgs, ... }:

{
  cri.packages.core = with pkgs; [
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
  ];
}
