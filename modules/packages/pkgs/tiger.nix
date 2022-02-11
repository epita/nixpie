{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.tiger.enable = lib.options.mkEnableOption "dev Tiger CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.tiger.enable {
    environment.systemPackages = with pkgs; [
      bison-epita
      havm
      nolimips
    ];
  };
}
