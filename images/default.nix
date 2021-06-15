{ lib
, nixpkgs
, nixpkgsMaster
, nixpkgsUnstable
, pkgset
, self
, system
, ...
}@inputs:
let
  nixosSystem = imageName:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit nixpkgsUnstable nixpkgsMaster;
        inherit imageName;
        nixpie = self;
      };

      modules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            system.name = imageName;
            networking.hostName = ""; # Use the DHCP provided hostname
            nix.nixPath = [
              "nixpkgs=${nixpkgs}"
              "nixpkgs-unstable=${nixpkgsUnstable}"
              "nixpkgs-master=${nixpkgsMaster}"
              "nixpie=${self}"
            ];

            nixpkgs = {
              inherit (pkgset) pkgs;
              overlays = [ self.overlay self.overrides.${system} ];
            };

            nix.registry = {
              nixpkgs.flake = nixpkgs;
              nixpkgsUnstable.flake = nixpkgsUnstable;
              nixpkgsMaster.flake = nixpkgsMaster;
              nixpie.flake = self;
            };

            # TODO: correctly set config.system.nixos.label
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local = import "${toString ./.}/${imageName}.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "nixpie" ]);

        in
        lib.concat flakeModules [ core global local ];
    };

  hosts = lib.genAttrs [
    "nixos-exec"
    "nixos-pie"
    "nixos-sup"
    "nixos-test"
  ]
    nixosSystem;
in
hosts
