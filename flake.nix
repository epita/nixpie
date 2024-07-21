{
  description = ''
    collection of Nix packages, NixOS modules and configurations used on
    EPITA's PIE
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs2311.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgsMaster.url = "github:NixOS/nixpkgs/master";

    machine-state.url = "git+https://gitlab.cri.epita.fr/cri/packages/machine-state.git";
    forgectl.url = "git+https://gitlab.cri.epita.fr/cri/tools/forgectl.git";

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
    , nixpkgs2311
    , nixpkgsUnstable
    , nixpkgsMaster

    , machine-state
    , forgectl

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
            permittedInsecurePackages = [
              "squid-6.8"
              "freeimage-unstable-2021-11-01"
            ];
          };
          overlays =
            (attrValues self.overlays) ++
            (optional withOverrides self.overrides.${system}) ++ [
              (import "${docker-nixpkgs}/overlay.nix")

              (final: prev: {
                machine-state = machine-state.packages.${system}.machine-state;
                forgectl = forgectl.packages.${system}.forgectl;
              })
            ];
        };

      pkgset = system: {
        pkgs = pkgImport nixpkgs system true;
        pkgs2311 = pkgImport nixpkgs2311 system false;
        pkgsUnstable = pkgImport nixpkgsUnstable system false;
        pkgsMaster = pkgImport nixpkgsMaster system false;
      };

      anySystemOutputs = {
        lib = import ./lib { inherit lib; };

        overlays = import ./pkgs/overlays.nix { inherit lib; };

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

        # works like hydraJobs
        gitlabCiJobs = {
          images.x86_64-linux = lib.mapAttrs (_: nixosConfig: nixosConfig.config.system.build.toplevel) self.nixosConfigurations;
          packages.x86_64-linux = lib.filterAttrs (name: _: !lib.hasSuffix "-docker" name) self.packages.x86_64-linux;
          checks.x86_64-linux = self.checks.x86_64-linux;
        };
      };

      multiSystemOutputs = eachDefaultSystem (system:
        let
          inherit (pkgset system) pkgs pkgs2311 pkgsUnstable pkgsMaster;
        in
        {
          checks = (import ./tests (recursiveUpdate inputs { inherit lib system; pkgset = pkgset system; }));

          devShells.default = pkgs.mkShell {
            name = "nixpie";
            buildInputs = with pkgs; [
              awscli
              git
              pkgsMaster.nix-diff
              nixpkgs-fmt
              nix-eval-jobs
              pre-commit
              shellcheck
            ];
          };

          apps =
            let
              checkList = builtins.attrNames self.checks.${system};
              imageList = builtins.attrNames self.nixosConfigurations;
              pkgsList = builtins.attrNames (lib.filterAttrs (name: _: !lib.hasSuffix "-docker" name) self.packages.${system});
              dockerList = builtins.attrNames (lib.filterAttrs (name: _: lib.hasSuffix "-docker" name) self.packages.${system});
              mkListApp = list: {
                type = "app";
                program = toString (pkgs.writeShellScript "list.sh" (lib.concatMapStringsSep "\n" (el: "echo '${el}'") list));
              };
            in
            {
              list-checks = mkListApp checkList;
              list-docker = mkListApp dockerList;
              list-images = mkListApp imageList;
              list-pkgs = mkListApp pkgsList;

              gen-secureboot-certs = {
                type = "app";
                program = toString (pkgs.writeShellScript "gen-secureboot-certs.sh" ''
                  set -e
                  cert_dir="$(git rev-parse --show-toplevel)/certs/secureboot"
                  for name in misc regular exam; do
                    ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 \
                      -keyout "$cert_dir/$name.key" -out "$cert_dir/$name.crt" \
                      -sha256 -days 36500 -nodes \
                      -addext "subjectAltName = URI:forge:securityclass:$name" \
                      -subj "/CN=SecureBoot Test Authority ($name)"
                  done
                '');
              };

              fetch-root-ca = {
                type = "app";
                program = toString (pkgs.writeShellScript "fetch-root-ca.sh" ''
                  set -e
                  cert_dir="$(git rev-parse --show-toplevel)/certs/"
                  ${pkgs.curl}/bin/curl -L --output "$cert_dir/public/root.crt" \
                    "https://vault.cri.epita.fr/v1/pki/ca/pem"
                '');
              };

              awscli = {
                type = "app";
                program = "${pkgs.awscli}/bin/aws";
              };
              nix-diff = {
                type = "app";
                program = "${pkgsMaster.nix-diff}/bin/nix-diff";
              };
              nix-eval-jobs = {
                type = "app";
                program = "${pkgs.nix-eval-jobs}/bin/nix-eval-jobs";
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

          overrides = import ./pkgs/overrides.nix { inherit pkgsUnstable pkgsMaster; };

          packages = (import ./pkgs { inherit lib pkgs; }) // (import ./images/docker.nix (recursiveUpdate inputs { inherit lib system; pkgset = pkgset system; }));
        });
    in
    recursiveUpdate multiSystemOutputs anySystemOutputs;
}
