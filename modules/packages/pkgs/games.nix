{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.games.enable = lib.options.mkEnableOption "games CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.games.enable {
    environment.systemPackages = with pkgs; [
      crispyDoom
      freeciv
      gtetrinet
      nethack
      openttd
      superTuxKart
      teeworlds
      warsow
      wesnoth
    ];
  };
}
