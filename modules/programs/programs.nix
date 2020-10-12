{ config, pkgs, lib, ... }:

with lib;
let
  genAttrs' = values: f: listToAttrs (map f values);
  pathsToImportedAttrs = paths:
    genAttrs' paths (
      path: {
        name = removeSuffix ".nix" (baseNameOf path);
        value = import path { inherit pkgs; };
      }
    );
  availablePrograms = pathsToImportedAttrs [
    ./programs-lists/core.nix
  ];
in
{
  options = {
    cri.packages = mkOption {
      type = with types; listOf str;
    };
  };

  config = {
    environment.systemPackages =
      flatten (
        attrValues (
          filterAttrs
            (
              n: _: (any (p: p == n) config.cri.packages)
            )
            availablePrograms
        )
      );
  };
}
