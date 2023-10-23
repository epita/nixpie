{ config, lib, inputs, ... }:

with lib;
let
  cfg = config.system.nixos;

  mkFlakeVersion = flake: "${flake.shortRev or "dirty"}";

  flakes = {
    inherit (inputs)
      nixpkgs
      nixpkgsUnstable
      nixpkgsMaster
      ;
  };

  versions = mapAttrsToList (name: flake: "${name}-${mkFlakeVersion flake}") flakes;

  nixpieLabel = "nixpie-" + (maybeEnv "NIXPIE_LABEL_VERSION" "pregit");
in
{
  system.nixos.label = concatStringsSep "_" ([ nixpieLabel ] ++ versions);
}
