{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SCIA";

  cri.packages = {
    pkgs = {
      scala.enable = true;
    };
  };
}
