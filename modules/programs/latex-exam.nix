{ pkgs, ... }:

{
  cri.programs.packageBundles.latexExam = with pkgs; [
    lyx
    texlive.combined.scheme-basic
  ];
}
