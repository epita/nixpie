{ config, lib, pkgs, ... }:
# Packages needed for the Parallel Programming course at EPITA

let
  # make SDL2 usable with -fsanitize=address
  sdlPkgs = pkgs.extend (import ../../../pkgs/sdl-compat-dlopen-overlay.nix);
in
{
  options = {
    cri.packages.pkgs.prpa.enable = lib.options.mkEnableOption "dev PRPA CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.prpa.enable {
    environment.systemPackages = [
      sdlPkgs.SDL2
      pkgs.perf-tools
      pkgs.tbb
    ];
  };
}
