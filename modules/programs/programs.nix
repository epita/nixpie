{ config, pkgs, lib, ... }:

with lib;
{
  options = {
    cri.programs = mkOption {
      type = with types; attrsOf (listOf package);
      description = "Set of package bundles";
    };
  };

  imports = [
    ./core.nix
    ./desktop.nix
    ./fuse.nix
  ];
}
