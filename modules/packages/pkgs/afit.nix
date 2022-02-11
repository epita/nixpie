{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.afit.enable = lib.options.mkEnableOption "dev AFIT CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.afit.enable {
    cri.packages.ocaml.afit.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      dune_2
      gmp
    ];
  };
}
