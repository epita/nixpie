{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  cri = {
    sddm.title = "NixOS Docker";
    packages.pkgs.docker-vm.enable = true;
  };

  netboot.enable = true;

}
