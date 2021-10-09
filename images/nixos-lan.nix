{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS LAN";

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    games
  ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev ];
}
