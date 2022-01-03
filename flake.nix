{
  # name = "nixpie";
  description = ''
    collection of Nix packages, NixOS modules and configurations used on
    EPITA's PIE
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11"; # change me to nixos-21.11 once it exists
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgsMaster.url = "github:NixOS/nixpkgs/master";

    # TODO: deprecate me
    nixpkgsMaths.url = "github:rissson/nixpkgs/nixos-maths-21.05";

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

    docker-nixpkgs = {
      url = "github:nix-community/docker-nixpkgs";
      flake = false;
    };

    futils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self

    , nixpkgs
    , nixpkgsUnstable
    , nixpkgsMaster

    , nixpkgsMaths

    , machine-state
    , nuc-led-setter

    , docker-nixpkgs

    , futils
    , flake-compat
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
          overlays =
            (attrValues self.overlays) ++
            (optional withOverrides self.overrides.${system}) ++ [
              (import "${docker-nixpkgs}/overlay.nix")
            ];
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
          checks = (import ./tests (recursiveUpdate inputs { inherit lib system; pkgset = pkgset system; }));

          devShell = pkgs.mkShell {
            name = "nixpie";
            buildInputs = with pkgs; [
              awscli
              git
              pkgsMaster.nix-diff
              nixpkgs-fmt
              pre-commit
              shellcheck
            ];
          };

          apps =
            let
              checkList = builtins.attrNames self.checks.${system};
              imageList = builtins.attrNames self.nixosConfigurations;
              pkgsList = builtins.attrNames (lib.filterAttrs (name: _: !lib.hasSuffix "-docker" name) self.packages.${system});
              mkListApp = list: {
                type = "app";
                program = toString (pkgs.writeShellScript "list.sh" (lib.concatMapStringsSep "\n" (el: "echo '${el}'") list));
              };
            in
            {
              list-checks = mkListApp checkList;
              list-images = mkListApp imageList;
              list-pkgs = mkListApp pkgsList;

              awscli = {
                type = "app";
                program = "${pkgs.awscli}/bin/aws";
              };
              nix-diff = {
                type = "app";
                program = "${pkgsMaster.nix-diff}/bin/nix-diff";
              };
              nixpkgs-fmt = {
                type = "app";
                program = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
              };
              skopeo = {
                type = "app";
                program = "${pkgs.skopeo}/bin/skopeo";
              };
            };

          overrides = import ./overlays/overrides.nix { inherit pkgsUnstable pkgsMaster; };

          packages = (self.lib.overlaysToPkgs self.overlays pkgs) // (import ./images/docker.nix (recursiveUpdate inputs { inherit lib system; pkgset = pkgset system; }));
        });
    in
    recursiveUpdate multiSystemOutputs anySystemOutputs;
}
