{ pkgs, ... }:

{
  cri.programs.packageBundles.core = with pkgs; [
    file
    git
    htop
    iftop
    iotop
    iproute
    ldns
    lsof
    man-pages
    man-pages-posix
    pciutils
    pipenv
    procps
    psmisc
    rsync
    screen
    tcpdump
    telnet
    term_size
    tmux
    tree
    udevil
    usbutils
    utillinux
    unzip
    wget
    zip
  ];

  cri.programs.pythonPackageBundles.core = pythonPackages: with pythonPackages; [
    pip
    virtualenv
  ];
}
