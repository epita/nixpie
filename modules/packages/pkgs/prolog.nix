{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.prolog.enable = lib.options.mkEnableOption "Prolog CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.prolog.enable {
    environment.systemPackages = with pkgs; [
      swiProlog
      gprolog
    ];
  };
}
