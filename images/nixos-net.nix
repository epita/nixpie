{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS NET";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      docker.enable = true;
      net.enable = true;
    };
  };

  cri.nswrappers.enable = true;
}
