{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS PIE - Piscine 2026";
  cri.sddm.theme = "epita-acu-2024";

  environment.systemPackages = with pkgs; [
    #spot-lrde
  ];

  cri.packages.pythonPackages.nixosPieCustom = p: with p; [
    networkx
    osmnx
  ];

  cri.packages = {
    pkgs = {
      cpp.enable = true;
      dev.enable = true;
      devFunctional.enable = true;
      java.enable = true;
      js.enable = true;
      podman.enable = true;
      prpa.enable = true;
      prolog.enable = true;
      spider.enable = true;
      sql.enable = true;
      thl.enable = true;
      tiger.enable = true;
    };
  };

  cri.nswrappers.enable = true;
}
