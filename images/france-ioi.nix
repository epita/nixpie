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

  environment.systemPackages = franceIOIPkgs;

  cri.packages = {
    pkgs = {
      dev.enable = true;
    };
  };
}
