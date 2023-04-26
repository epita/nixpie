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

  imageName = "testing-image";

  modules = import ../images/modules.nix inputs imageName;

  makeTest = test: lib.nixos.runTest {
    node.specialArgs = import ../images/special-args.nix inputs imageName;

    defaults = {
      imports = modules.flakeModules ++ [
        modules.core
        modules.global
        self.nixosModules.profiles.tests
      ];

      documentation.nixos.enable = mkForce false;
    };

    imports = [ test ];

    hostPkgs = pkgs;
  };

  tests = {
    criterion = ./criterion.nix;
    dotnet = ./dotnet.nix;
    gtest = ./gtest.nix;
    # Not working, again.
    # login-epita = ./login-epita.nix;
    node-exporter = ./node-exporter.nix;
    nswrappers = ./nswrappers.nix;
    spider = ./spider.nix;
    version = ./version.nix;
  };
in
mapAttrs
  (name: testPath:
  let
    f = import testPath;
    test = if isFunction f then f (recursiveUpdate inputs { inherit pkgs; }) else f;
  in
  makeTest ({ inherit name; } // test))
  tests
