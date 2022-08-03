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
      "nixpie=${self}"
    ];

    nixpkgs = {
      inherit (pkgset) pkgs;
      overlays = [ self.overrides.${system} ] ++ (lib.attrValues self.overlays);
    };

    nix.registry = {
      nixpkgs.flake = nixpkgs;
      nixpkgsUnstable.flake = nixpkgsUnstable;
      nixpkgsMaster.flake = nixpkgsMaster;
      nixpie.flake = self;
    };

    environment.etc."nixos-version".text = if (self ? rev) then self.rev else "";
    system.configurationRevision = null; # triggers rebuild of mandb
  };

  flakeModules =
    builtins.attrValues (removeAttrs self.nixosModules [ "profiles" "nixpie" ]);
}
