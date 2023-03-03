{ pkgsUnstable, pkgsMaster }:

final: prev: {
  inherit (pkgsUnstable)
    httplib;
}
