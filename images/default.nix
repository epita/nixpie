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

      specialArgs = {
        inherit inputs;
        nixpie = self;
        inherit imageName;
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
    in
    lib.nixosSystem {
      inherit system specialArgs;


      modules = modules ++ [
        ({ lib, modulesPath, ... }: {
          system.build.vm = (import "${modulesPath}/../lib/eval-config.nix" {
            inherit system specialArgs;
            modules = modules ++ [
              "${modulesPath}/virtualisation/qemu-vm.nix"
              {
                netboot.enable = lib.mkVMOverride false;
              }
            ];
          }).config.system.build.vm;
        })
      ];
    };

  hosts = lib.mapAttrs nixosSystem {
    "nixos-exec" = { };
    "nixos-nlp" = { };
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
