{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Prepa";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      ocaml.enable = true;
      afit.enable = true;
      csharp.enable = true;
      asm.enable = true;
      gtk.enable = true;
      rust.enable = true;
      sdl.enable = true;
      thl.enable = true;
    };
  };
}
