{ lib }:

with lib;

let
  tlAllPackages = import ./top-level/all-packages.nix;

  mkCallPackage = pkgArgs: final: prev:
    let
      defaultArgs = {
        callPackage = final: prev: final.callPackage;
        args = final: prev: { };
      };

      p =
        if builtins.isAttrs pkgArgs then
          (defaultArgs // pkgArgs)
        else
          defaultArgs // { path = pkgArgs; };
    in
    (p.callPackage final prev) p.path (p.args final prev);


  mkOverlay = name: pkgArgs: final: prev: {
    "${name}" = mkCallPackage pkgArgs final prev;
  };

  allPackages = mapAttrs mkOverlay tlAllPackages;
in
allPackages
