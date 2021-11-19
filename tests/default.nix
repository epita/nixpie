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

  makeTest = test: ((import "${nixpkgs}/nixos/lib/testing-python.nix" {
    inherit system pkgs;
    specialArgs = import ../images/special-args.nix inputs "testing-image";
    extraConfigurations =
      let
        inherit (import ../images/modules.nix inputs "testing-image") core global flakeModules;
      in
      flakeModules ++ [ core global self.nixosModules.profiles.tests ];
  }).makeTest test).overrideAttrs (oldAttrs: {
    # See https://github.com/NixOS/nixpkgs/blob/release-21.05/nixos/lib/testing-python.nix
    # We override the return of `runTests` to output HTML and XML

    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.libxslt ];

    buildCommand = ''
      mkdir -p $out
      LOGFILE=$out/log.xml tests='exec(os.environ["testScript"])' ${oldAttrs.passthru.driver}/bin/nixos-test-driver

      # Generate a pretty-printed log.
      xsltproc --output $out/log.html ${./log/log2html.xsl} $out/log.xml
    '';
  });

  tests = {
    criterion = ./criterion.nix;
    login-epita = ./login-epita.nix;
    node-exporter = ./node-exporter.nix;
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
