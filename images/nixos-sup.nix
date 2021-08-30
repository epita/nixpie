{ config, pkgs, ... }:

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

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    devOcaml
    devCsharp
    nixosSupPkgs
  ];
}
