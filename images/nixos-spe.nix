{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SPE";

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    devAsm
    devGtk
    devSdl
    devRust
  ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [
    dev
    (ps: with ps; [
      graphviz
    ])
  ];

  environment.systemPackages = with pkgs; [
    graphviz
  ];
}
