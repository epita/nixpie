{ pkgs, ... }:

{
  cri.programs.devOcaml = with pkgs; [
    ocaml
    opam
  ];
}
