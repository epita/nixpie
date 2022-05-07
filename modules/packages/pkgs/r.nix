{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.r.enable = lib.options.mkEnableOption "dev R CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.r.enable {
    environment.systemPackages = with pkgs; [
      rWrapper
    ];
  };
}
