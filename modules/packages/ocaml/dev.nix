{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.ocaml.dev.enable = lib.options.mkEnableOption "dev OCaml CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.ocaml.dev.enable {
    cri.packages.ocamlPackages = with pkgs.ocamlPackages; [
      findlib
      graphics
    ];
  };
}
