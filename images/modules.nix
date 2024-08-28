{ lib
, nixpkgs
, nixpkgsMaster
, nixpkgsUnstable
, pkgset
, self
, system
, ...
}@inputs:

imageName:
{
  core = self.nixosModules.profiles.core;

  global = {
    system.name = imageName;
    networking.hostName = ""; # Use the DHCP provided hostname
    nix.nixPath = [
      "nixpkgs=${nixpkgs}"
      "nixpkgs-unstable=${nixpkgsUnstable}"
      "nixpkgs-master=${nixpkgsMaster}"
    ];

    nixpkgs = {
      inherit (pkgset) pkgs;
      overlays = [ self.overrides.${system} ] ++ (lib.attrValues self.overlays);
    };

    nix.registry = {
      nixpkgs.flake = nixpkgs;
      nixpkgsUnstable.flake = nixpkgsUnstable;
      nixpkgsMaster.flake = nixpkgsMaster;
      nixpie = {
        from = {
          id = "nixpie";
          type = "indirect";
        };
        to = {
          type = "git";
          url = "https://gitlab.cri.epita.fr/forge/infra/nixpie.git";
        };
      };
    };

    environment.etc."nixos-version".text = lib.maybeEnv "NIXPIE_LABEL_VERSION" "pregit";
    system.configurationRevision = null; # triggers rebuild of mandb
  };

  flakeModules =
    builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "nixpie" ]);
}
