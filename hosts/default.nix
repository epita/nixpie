{ lib
, system
, pkgset
, self
, nixos
, nixpkgs
, futils
}:
let
  config = imageName:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit (pkgset) nixpkgs;
        nixpie = self;
        inherit imageName;
      };

      modules =
        let
          core = self.nixosModules.profiles.core;

          global = {
            system.name = imageName;
            networking.hostName = ""; # Use the DHCP provided hostname
            nix.nixPath =
              let
                path = toString ../.;
              in
              [
                "nixos=${nixos}"
                "nixpkgs=${nixpkgs}"
                "nixpkgs-overlays=${path}/overlays"
                "nixpie=${path}"
              ];

            nixpkgs = { pkgs = pkgset.nixos; };

            nix.registry = {
              nixos.flake = nixos;
              nixpkgs.flake = nixpkgs;
              nixpie.flake = self;
            };

            # TODO: correctly set config.system.nixos.label
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          overrides = {
            nixpkgs.overlays =
              let
                override = import ../pkgs/override.nix pkgset.nixpkgs;

                overlay = pkg: _: _: {
                  "${pkg.pname}" = pkg;
                };
              in
              map overlay override;
          };

          local = import "${toString ./.}/${imageName}.nix";

          flakeModules =
            builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "nixpie" ]);

        in
        lib.concat flakeModules [ core global local overrides ];
    };

  hosts = lib.genAttrs [
    "nixos-pie"
    "nixos-exec"
  ]
    config;
in
hosts
