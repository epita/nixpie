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
  # We must assign a very high priority because `nixos-test-base` is overriding
  # this value with `lib.mkForce` when running checks.
  system.nixos.label = mkOverride 25 (concatStringsSep "_" ([ nixpieLabel ] ++ versions));
}
