{
  # name = "nixpie";
  description = ''
    nixpie: collection of Nix packages, NixOS modules and configurations used
    at EPITA's PIE
  '';

  inputs = {
    nixos.url = "nixpkgs/nixos-20.09";
    nixpkgs.url = "nixpkgs/master";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixos, nixpkgs, futils } @ inputs:
    let
      inherit (nixos) lib;
      inherit (lib) attrValues genAttrs recursiveUpdate;
      inherit (futils.lib) defaultSystems eachDefaultSystem;

      nixpkgsFor = pkgs: system: import pkgs {
        inherit system;
        overlays = attrValues self.overlays;
        config = { allowUnfree = true; };
      };

      pkgsetFor = genAttrs defaultSystems (system: {
        nixos = nixpkgsFor nixos system;
        nixpkgs = nixpkgsFor nixpkgs system;
      });
    in
    recursiveUpdate

      {
        lib = import ./lib { inherit lib; };

        overlays = import ./overlays;

        overlay = self.overlays.packages;

        nixosModules = (import ./modules) // {
          profiles = import ./profiles;
          nixpie = import ./modules/nixpie.nix;
        };

        nixosConfigurations =
          let
            system = "x86_64-linux";
            pkgset' = pkgsetFor.${system};
          in
          import ./hosts (inputs // {
            inherit lib system;
            pkgset = pkgset';
          });
      }

      (eachDefaultSystem (system:
        let
          pkgset = pkgsetFor.${system};
        in
        {
          devShell = pkgset.nixpkgs.mkShell {
            name = "nixpie";
            nativeBuildInputs = with pkgset.nixpkgs; [
              git
              nixpkgs-fmt
            ];
          };

          packages = {
            inherit (pkgset.nixos)
              i3lock
              sddm-epita-themes
              term_size
              ;
          };
        }
      ));
}
