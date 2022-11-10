{ pkgsUnstable, pkgsMaster }:

final: prev: {
  inherit (pkgsUnstable)
    dotnet-sdk_7
    ;
}
