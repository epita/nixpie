{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.core.enable = lib.options.mkEnableOption "core CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.core.enable {
    cri.packages.python.core.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      file
      forgectl
      git
      htop
      iftop
      iotop
      iproute
      ldns
      lsof
      man-pages
      man-pages-posix
      mtr
      ncdu
      pciutils
      pipenv
      procps
      psmisc
      rsync
      screen
      tcpdump
      inetutils
      tmux
      tree
      usbutils
      utillinux
      unzip
      wget
      zip
    ];
  };
}
