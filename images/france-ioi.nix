{ config, pkgs, ... }:

let
  franceIOIPkgs = with pkgs; [
    codeblocksFull
    ddd
    eclipses.eclipse-sdk
    gedit
    gource
    libsForQt5.kate
    sublime3
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
      java.enable = true;
    };
  };
}
