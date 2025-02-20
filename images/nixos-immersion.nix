{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Immersion";
  cri.xfce.enable = true;

  environment.systemPackages = with pkgs; [
    gedit
    gimp
    weka
  ];

  environment.pathsToLink = [ "/share/weka" ];

  cri.packages.pythonPackages.nixosPieCustom = p: with p; [
    opencv4
    matplotlib
    numpy
    jupyter
  ];

  cri.packages = {
    pkgs = {
      dev.enable = true;
      csharp.enable = true;
    };
  };
}
