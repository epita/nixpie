{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.cri.packages;
in
{
  options = {
    cri.packages = {
      pythonPackages = mkOption {
        default = [ ];
        type = with types; attrsOf (functionTo (listOf package));
        description = "Python packages to install.";
      };

      ocamlPackages = mkOption {
        default = [ ];
        type = with types; listOf package;
        description = "Ocaml packages to install.";
      };
    };
  };

  imports = [
    ./pkgs
    ./python
    ./ocaml
  ];

  config = {
    environment.systemPackages = [
      ((pkgs.python3.withPackages (ps: flatten (map (set: set ps) (attrsets.attrValues cfg.pythonPackages)))).override (args: { ignoreCollisions = true; }))
    ] ++ cfg.ocamlPackages;

    environment.variables = {
      OCAMLPATH = concatMapStringsSep ":" (pkg: "${pkg}/lib/ocaml/${pkgs.ocaml.version}/site-lib/") cfg.ocamlPackages;
      CAML_LD_LIBRARY_PATH = concatMapStringsSep ":" (pkg: "${pkg}/lib/ocaml/${pkgs.ocaml.version}/site-lib/stublibs") cfg.ocamlPackages;
    };
  };
}
