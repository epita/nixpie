{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "Nixos NTS";

  cri.packages = {
    pkgs = {
      nts.enable = true;
    };
  };
}
