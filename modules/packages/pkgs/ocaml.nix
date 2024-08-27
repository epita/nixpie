{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.ocaml.enable = lib.options.mkEnableOption "dev OCaml CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.ocaml.enable {
    cri.packages.ocaml.dev.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      ocaml
      opam
      ocaml-top
    ];
  };
}
