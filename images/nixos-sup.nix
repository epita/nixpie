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

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    devOcaml
    devAfit
    devCsharp
    nixosSupPkgs
  ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev ];
  cri.programs.ocamlPackages = with config.cri.programs.ocamlPackageBundles; [ dev devAfit ];
}
