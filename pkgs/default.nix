{ lib, pkgs }:

let
  allPackagesNames = builtins.attrNames (import ./top-level/all-packages.nix);

  drvs = lib.filterAttrs (name: _: builtins.elem name allPackagesNames) pkgs;

  systemDrvs = lib.filterAttrs
    (_: drv: builtins.elem pkgs.system (drv.meta.platforms))
    drvs;
in
systemDrvs
