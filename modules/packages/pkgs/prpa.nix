{ config, lib, pkgs, ... }:
# Packages needed for the Parallel Programming course at EPITA

{
  options = {
    cri.packages.pkgs.prpa.enable = lib.options.mkEnableOption "dev PRPA CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.prpa.enable {
    environment.systemPackages = with pkgs; [
      SDL2
      perf-tools
      tbb
    ];
  };
}
