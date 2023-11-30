{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.ocaml.ssie.enable = lib.options.mkEnableOption "ssie OCaml CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.ocaml.ssie.enable {
    cri.packages.ocamlPackages = with pkgs.ocamlPackages; [
      lustre-v6
    ];
  };
}
