{ pkgsUnstable, pkgsMaster }:

final: prev: {
  inherit (pkgsUnstable)
    chromium
    discord
    firefox
    firefox-unwrapped
    steam
    teams
    wrapFirefox
    ;
}
