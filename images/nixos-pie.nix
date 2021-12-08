{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS PIE";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev devThl ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev devThl ];

  environment.systemPackages = with pkgs; [ ciscoPacketTracer8 ];
}
