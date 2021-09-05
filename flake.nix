{
  # name = "nixpie";
  description = ''
    collection of Nix packages, NixOS modules and configurations used on
    EPITA's PIE
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgsMaster.url = "github:NixOS/nixpkgs/master";

    machine-state = {
      url = "git+https://gitlab.cri.epita.fr/cri/packages/machine-state.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nuc-led-setter = {
      url = "git+https://gitlab.cri.epita.fr/cri/packages/nuc-led-setter.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    futils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self

    , nixpkgs
    , nixpkgsUnstable
    , nixpkgsMaster

    , machine-state
    , nuc-led-setter

    , futils
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) attrValues optional recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem;

      pkgImport = pkgs: system: withOverrides:
        import pkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = (attrValues self.overlays) ++ (optional withOverrides self.overrides.${system});
        };

      pkgset = system: {
        pkgs = pkgImport nixpkgs system true;
        pkgsUnstable = pkgImport nixpkgsUnstable system false;
        pkgsMaster = pkgImport nixpkgsMaster system false;
      };

      anySystemOutputs = {
        lib = import ./lib { inherit lib; };

        overlays = (import ./overlays) // {
          packages = import ./pkgs;
        };
        overlay = self.overlays.packages;

        nixosModules = (import ./modules) // {
          profiles = import ./profiles;
          nixpie = import ./modules/nixpie.nix;
        };

        nixosConfigurations =
          let
            system = "x86_64-linux";
          in
          import ./images (
            recursiveUpdate inputs {
              inherit lib system;
              pkgset = pkgset system;
            }
          );
      };

      multiSystemOutputs = eachDefaultSystem (system:
        let
          inherit (pkgset system) pkgs pkgsUnstable pkgsMaster;
        in
        {
          devShell = pkgs.mkShell {
            name = "nixpie";
            buildInputs = with pkgs; [
              awscli
              git
              nixpkgs-fmt
              pre-commit
            ];
          };

          overrides = import ./overlays/overrides.nix { inherit pkgsUnstable pkgsMaster; };

          packages = self.lib.overlaysToPkgs self.overlays pkgs;
        });
    in
    recursiveUpdate multiSystemOutputs anySystemOutputs;
}
