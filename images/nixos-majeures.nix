{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Majeures";

  cri.packages = {
    pkgs = {
      coq.enable = true;
    };
  };
}
