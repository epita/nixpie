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
    };
  };

  imports = [
    ./core.nix
    ./desktop.nix
    ./dev.nix
    ./dev-asm.nix
    ./dev-csharp.nix
    ./dev-gtk.nix
    ./dev-ocaml.nix
    ./dev-rust.nix
    ./dev-sdl.nix
    ./dev-sql.nix
    ./fuse.nix
  ];

  config = {
    environment.systemPackages = (flatten cfg.packages) ++ [
      (pkgs.python3.withPackages (ps: flatten (map (set: set ps) cfg.pythonPackages)))
    ];
  };
}
