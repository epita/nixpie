{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SPE";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      asm.enable = true;
      gtk.enable = true;
      rust.enable = true;
      sdl.enable = true;
      thl.enable = true;
    };
  };
}
