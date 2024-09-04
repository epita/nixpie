{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.ocaml.ssse.enable = lib.options.mkEnableOption "ssse OCaml CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.ocaml.ssse.enable {
    cri.packages.ocamlPackages = with pkgs.ocamlPackages; [
      lustre-v6
    ];
  };
}
