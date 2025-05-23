{ lib
, nixpkgs
, nixpkgsMaster
, nixpkgsUnstable
, docker-nixpkgs
, pkgset
, self
, system
, ...
}@inputs:
with lib;
let
  inherit (pkgset) pkgs;
  mkDockerImage = image: config: pkgs.dockerTools.buildLayeredImage {
    name = image;
    contents = config.system.path;
    extraCommands = ''
      mkdir -p /tmp
    '';
    config = {
      # See profiles/core/default.nix and modules/packages/default.nix
      Env =
        let
          OCAMLPATH = config.environment.variables.OCAMLPATH;
          CAML_LD_LIBRARY_PATH = config.environment.variables.CAML_LD_LIBRARY_PATH;
        in
        [
          "NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu=-I/include"
          "NIX_CFLAGS_LINK_x86_64_unknown_linux_gnu=-L/lib"
          "PKG_CONFIG_PATH=/lib/pkgconfig"
          "OCAMLPATH=${OCAMLPATH}"
          "CAML_LD_LIBRARY_PATH=${CAML_LD_LIBRARY_PATH}"
        ];
    };
  };
in
(lib.mapAttrs' (name: build: lib.nameValuePair ("${name}-docker") (mkDockerImage name build.config)) (filterAttrs (name: _: !hasPrefix "exam-" name && !hasSuffix "-vm" name) self.nixosConfigurations)) // {
  nix-docker = pkgs.docker-nixpkgs.nix.override {
    nix = pkgs.nixVersions.stable;
    extraContents = [
      pkgs.findutils
      pkgs.jq
      (pkgs.writeTextFile {
        name = "nix.conf";
        destination = "/etc/nix/nix.conf";
        text = ''
          experimental-features = nix-command flakes ca-references
          substituters = https://cache.nixos.org http://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr
          trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo=
        '';
      })
    ];
  };
}
