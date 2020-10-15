{
  # name = "nixpie";

  description = ''
    nixpie: collection of Nix packages, NixOS modules and configurations used
    at EPITA's PIE
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  };

  outputs = { self, nixpkgs } @ inputs:
    let
      inherit (builtins) attrNames attrValues readDir;
      inherit (nixpkgs) lib;
      inherit (lib) hasSuffix removeSuffix recursiveUpdate genAttrs filterAttrs;
      inherit (self.lib.utils) pathsToImportedAttrs;

      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = attrValues self.overlays;
        config = { allowUnfree = true; };
      };

    in
    {
      devShell."${system}" = pkgs.mkShell {
        name = "nixpie";
        nativeBuildInputs = with pkgs; [
          git
          nixpkgs-fmt
          nix-linter
        ];
      };

      lib.utils = import ./lib/utils.nix { inherit lib; };

      overlay = import ./pkgs;

      overlays =
        let
          overlayDir = ./overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (attrNames (filterAttrs (n: _: hasSuffix ".nix" n) (readDir overlayDir)));
        in
        pathsToImportedAttrs overlayPaths;

      packages.${system} =
        let
          packages = self.overlay pkgs pkgs;
          overlays = lib.filterAttrs (n: _: n != "pkgs") self.overlays;
          overlayPkgs =
            genAttrs
              (attrNames overlays)
              (name: (overlays."${name}" pkgs pkgs)."${name}");
        in
        recursiveUpdate packages overlayPkgs;

      nixosModules =
        let
          # modules
          modulesList = import ./modules/list.nix;
          modulesAttrs = pathsToImportedAttrs modulesList;

          # profiles
          profilesList = import ./profiles/list.nix;
          profilesAttrs = { profiles = pathsToImportedAttrs profilesList; };
        in
        recursiveUpdate modulesAttrs profilesAttrs;

      nixosConfigurations =
        import ./hosts (
          lib.recursiveUpdate inputs {
            inherit pkgs lib system;
          }
        );
    };
}
