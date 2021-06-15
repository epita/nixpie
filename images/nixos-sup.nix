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

  environment.systemPackages = with config.cri.programs; devOcaml ++ devCsharp ++ nixosSupPkgs;

  netboot.enable = true;
  cri.sddm.title = "NixOS SUP";
}
