{ config, pkgs, ... }:

let
  franceIOIPkgs = with pkgs; [
    gnome.gedit
    gource
    vscode
  ];
in
{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "France IOI";
  cri.xfce.enable = true;

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    franceIOIPkgs
  ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev ];
}
