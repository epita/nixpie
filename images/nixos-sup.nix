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

  environment.systemPackages = with config.cri.programs;
    dev ++
    devOcaml ++
    devCsharp ++
    nixosSupPkgs;
}
