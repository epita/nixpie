{ pkgs, ... }:

{
  cri.programs.packageBundles.devOcaml = with pkgs; [
    ocaml
    opam
  ];
}
