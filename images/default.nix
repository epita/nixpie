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
  nixosSystem = imageName: { isVM ? false }:
    let
      _imageName = if isVM then lib.removeSuffix "-vm" imageName else imageName;
    in
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
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

            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local = import "${toString ./.}/${_imageName}.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "nixpie" ]);

        in
        flakeModules ++ [ core global local ] ++ (lib.optional isVM ../profiles/vm);
    };

  hosts = lib.mapAttrs nixosSystem {
    "nixos-exec" = { };
    "nixos-pie" = { };
    "nixos-sup" = { };
    "nixos-spe" = { };
    "nixos-test" = { };

    "exam-pie" = { };

    "nixos-pie-vm" = { isVM = true; };
    "nixos-sup-vm" = { isVM = true; };
    "nixos-spe-vm" = { isVM = true; };
    "nixos-test-vm" = { isVM = true; };
  };
in
hosts
