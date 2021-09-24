{ lib
, nixpkgs
, nixpkgsMaster
, nixpkgsUnstable
, pkgset
, self
, system
, ...
}@inputs:
let
  inherit (pkgset) pkgs;
  mkDockerImage = image: config: pkgs.dockerTools.buildLayeredImage {
    name = image;
    contents = config.system.path;
    extraCommands = ''
      mkdir -p /tmp
    '';
    config = {
      # See profiles/core/default.nix
      Env = [
        "NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu=-I/include"
        "NIX_CFLAGS_LINK_x86_64_unknown_linux_gnu=-L/lib"
        "PKG_CONFIG_PATH=/lib/pkgconfig"
      ];
    };
  };
in
lib.mapAttrs' (name: build: lib.nameValuePair ("${name}-docker") (mkDockerImage name build.config)) self.nixosConfigurations
