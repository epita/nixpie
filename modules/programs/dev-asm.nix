{ pkgs, ... }:
{
  cri.programs.packageBundles.devAsm = with pkgs; [
    dosbox
    geany
    m68k
    nasm
  ];
}
