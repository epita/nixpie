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
    ./programs-lists/fuse.nix
    ./programs-lists/desktop.nix
  ];
in
{
  options = {
    cri.programs = mkOption {
      type = with types; attrsOf (listOf package);
      description = "Set of package bundles";
    };
  };

  config = {
    cri.programs = availablePrograms;
  };
}
