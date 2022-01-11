{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS PIE";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev devSQL devThl devJava ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev devThl ];

  cri.nswrappers.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };
}
