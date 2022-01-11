{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS NET";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev ];

  environment.systemPackages = with pkgs; [ ciscoPacketTracer8 ];

  cri.nswrappers.enable = true;
}
