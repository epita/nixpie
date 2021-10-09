{ pkgs, ... }:

{
  cri.programs.packageBundles.games = with pkgs; [
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
}

