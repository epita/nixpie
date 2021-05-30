{ pkgsUnstable, pkgsMaster }:

final: prev: {
  inherit (pkgsUnstable)
    chromium
    discord
    firefox
    teams
    ;
}
