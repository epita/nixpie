{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.cri.programs;
in
{
  options = {
    cri.programs = {
      packageBundles = mkOption {
        default = { };
        type = with types; attrsOf (listOf package);
        description = "Set of package bundles";
      };

      pythonPackageBundles = mkOption {
        type = with types; attrsOf (functionTo (listOf package));
        default = { };
        description = "Set of python package bundles.";
        example = literalExample "{ core = pythonPackages: with pythonPackages; [ pip virtualenv ]; }";
      };

      ocamlPackageBundles = mkOption {
        type = with types; attrsOf (listOf package);
        default = { };
        description = "Set of ocaml package bundles.";
        example = literalExample "{ core = with pkgs.ocamlPackages; [ findlib ]; }";
      };

      packages = mkOption {
        default = [ ];
        type = with types; listOf (oneOf [ package (listOf package) ]);
        description = "Packages to install.";
      };

      pythonPackages = mkOption {
        default = [ ];
        type = with types; listOf (functionTo (listOf package));
        description = "Python packages to install.";
      };

      ocamlPackages = mkOption {
        default = [ ];
        type = with types; listOf (listOf package);
        description = "Ocaml packages to install.";
      };
    };
  };

  imports = [
    ./core.nix
    ./desktop.nix
    ./dev.nix
    ./dev-afit.nix
    ./dev-asm.nix
    ./dev-csharp.nix
    ./dev-gtk.nix
    ./dev-java.nix
    ./dev-lisp.nix
    ./dev-ocaml.nix
    ./dev-rust.nix
    ./dev-sdl.nix
    ./dev-spider.nix
    ./dev-sql.nix
    ./dev-thl.nix
    ./dev-tiger.nix
    ./fuse.nix
    ./games.nix
    ./gpgpu.nix
    ./latex-exam.nix
    ./opengl.nix
  ];

  config = {
    environment.systemPackages = (flatten cfg.packages) ++ [
      ((pkgs.python3.withPackages (ps: flatten (map (set: set ps) cfg.pythonPackages))).override (args: { ignoreCollisions = true; }))
    ] ++ (flatten cfg.ocamlPackages);

    environment.variables = {
      OCAMLPATH = concatMapStringsSep ":" (pkg: "${pkg}/lib/ocaml/${pkgs.ocaml.version}/site-lib/") (flatten cfg.ocamlPackages);
      CAML_LD_LIBRARY_PATH = concatMapStringsSep ":" (pkg: "${pkg}/lib/ocaml/${pkgs.ocaml.version}/site-lib/stublibs") (flatten cfg.ocamlPackages);
    };
  };
}
