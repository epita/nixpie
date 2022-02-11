{ pkgs, ... }:

{
  cri.programs.packageBundles.devLisp = with pkgs; [
    sbcl
    clisp
    emacs27Packages.slime
  ];
}
