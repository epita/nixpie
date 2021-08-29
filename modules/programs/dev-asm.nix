{ pkgs, ... }:

{
  cri.programs.packageBundles.devAsm = with pkgs; [
    dosbox
    geany
    nasm
  ];
}
