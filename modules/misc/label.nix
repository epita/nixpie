{ config, lib, inputs, ... }:

with lib;
let
  cfg = config.system.nixos;

  mkFlakeVersion = flake: "${substring 0 8 (flake.lastModifiedDate or flake.lastModified or "19700101")}-${flake.shortRev or "dirty"}";

  flakes = {
    inherit (inputs)
      nixpkgs
      nixpkgsUnstable
      nixpkgsMaster
      ;
    nixpie = inputs.self;
  };
in
{
  options = {
    system.nixos = {
      labels = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      versions = mkOption {
        type = with types; attrsOf str;
      };
    };
  };

  config = {
    system.nixos.versions = mapAttrs (_: flake: mkFlakeVersion flake) flakes;

    system.nixos.label = concatStringsSep "_" cfg.labels;

    system.nixos.labels = [
      (concatStringsSep "-" (sort (x: y: x < y) cfg.tags))
    ] ++ (mapAttrsToList (flake: version: "${flake}-${version}") cfg.versions);
  };
}
