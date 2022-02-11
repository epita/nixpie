{ config, pkgs, lib, ... }:

with lib;

let
  nixosSupPkgs = with pkgs; [
    gnome.gedit
    gource
  ];
in
{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SUP";
  cri.xfce.enable = true;

  cri.packages = {
    pkgs = {
      dev.enable = true;
      ocaml.enable = true;
      afit.enable = true;
      csharp.enable = true;
    };
  };

  environment.systemPackages = nixosSupPkgs;
}
