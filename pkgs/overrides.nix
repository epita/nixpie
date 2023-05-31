{ pkgsUnstable, pkgsMaster }:

final: prev: {
  inherit (pkgsUnstable)
    httplib;

  python3 = prev.python3.override {
    packageOverrides = python-self: python-super: {
      inherit (pkgsUnstable.python3Packages) pysqlcipher3;
    };
  };
}
