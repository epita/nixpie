{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.games.enable = lib.options.mkEnableOption "games CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.games.enable {
    environment.systemPackages = with pkgs; [
      crispy-doom
      freeciv
      nethack
      openttd
      superTuxKart
      teeworlds
      wesnoth
    ];
  };
}
