{ pkgs, ... }:

{
  cri.programs.packageBundles.core = with pkgs; [
    git
    htop
    iproute
    lsof
    man-pages
    man-pages-posix
    pipenv
    psmisc
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

  cri.programs.pythonPackageBundles.core = pythonPackages: with pythonPackages; [
    pip
    virtualenv
  ];
}
