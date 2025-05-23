{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  cri.packages = {
    pkgs = {
      docker.enable = true;
      dev.enable = true;
    };
  };

  netboot.enable = true;
  cri.sddm.title = "NixOS Docker";
}
