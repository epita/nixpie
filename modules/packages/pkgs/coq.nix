{ config, lib, pkgs, ... }:

# TICKET #39777
{
  options = {
    cri.packages.pkgs.coq.enable = lib.options.mkEnableOption "dev Coq CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.coq.enable {
    environment.systemPackages = with pkgs; [
      coq_8_20
      coqPackages_8_20.coqide
    ];
  };
}
