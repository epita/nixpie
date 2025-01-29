{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.octave.enable = lib.options.mkEnableOption "octave package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.octave.enable {
    environment.systemPackages = with pkgs; [
      octaveFull
    ];
  };
}
