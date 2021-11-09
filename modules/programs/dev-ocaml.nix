{ pkgs, ... }:

{
  cri.programs.packageBundles.devOcaml = with pkgs; [
    ocaml
    opam
  ];
  cri.programs.ocamlPackageBundles.dev = with pkgs.ocamlPackages; [
    findlib
    graphics
  ];
}
