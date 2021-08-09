{ pkgs, ... }:

{
  cri.programs.packageBundles.devAsm = with pkgs; [
    dosbox
    nasm
  ];
}
