{ pkgs, ... }:

{
  cri.programs.packageBundles.devOcaml = with pkgs; [
    ocaml
    ocamlPackages.findlib
    ocamlPackages.graphics
    opam
  ];
}
