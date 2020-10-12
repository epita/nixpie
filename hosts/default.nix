{ lib
, pkgs
, system
, self
, nixpkgs
, ...
}:
let
  inherit (builtins) attrValues removeAttrs;

  config = imageName:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit imageName;
        nixpie = self;
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
                "nixpkgs=${nixpkgs}"
                "nixos=${nixpkgs}"
                "nixpie=${path}"
              ];

            nixpkgs = { inherit pkgs; };

            nix.registry = {
              nixos.flake = nixpkgs;
              nixpkgs.flake = nixpkgs;
              nixpie.flake = self;
            };

            # TODO: correctly set config.system.nixos.label
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          overrides = {
            nixpkgs.overlays =
              let
                override = import ../pkgs/override.nix pkgs;

                overlay = pkg: _: _: {
                  "${pkg.pname}" = pkg;
                };
              in
              map overlay override;
          };

          local = import "${toString ./.}/${imageName}.nix";

          flakeModules =
            attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        lib.concat flakeModules [ core global local overrides ];
    };

  hosts = lib.genAttrs [ ]
    config;
in
hosts
