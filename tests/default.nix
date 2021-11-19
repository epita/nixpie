{ lib
, nixpkgs
, pkgset
, self
, system
, ...
}@inputs:

with lib;

let
  inherit (pkgset) pkgs;

  makeTest = (import "${nixpkgs}/nixos/lib/testing-python.nix" {
    inherit system pkgs;
    specialArgs = import ../images/special-args.nix inputs "testing-image";
    extraConfigurations =
      let
        inherit (import ../images/modules.nix inputs "testing-image") core global flakeModules;
      in
      flakeModules ++ [ core global self.nixosModules.profiles.tests ];
  }).makeTest;

  tests = {
    version = ./version.nix;
  };
in
mapAttrs
  (name: testPath:
    let
      f = import testPath;
      test = if isFunction f then f inputs else f;
    in
    makeTest ({ inherit name; } // test))
  tests
