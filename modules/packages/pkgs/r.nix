{ config, lib, pkgs, ... }:

let
  nixpieRPackages = with pkgs.rPackages; [
    FactoMineR
  ];
in
{
  options = {
    cri.packages.pkgs.r.enable = lib.options.mkEnableOption "dev R CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.r.enable {
    environment.systemPackages = with pkgs; [
      (rWrapper.override { packages = nixpieRPackages; })
      (rstudioWrapper.override { packages = nixpieRPackages; })
    ];
  };
}
