{ pkgs, ... }:

{
  cri.programs.devAsm = with pkgs; [
    dosbox
    nasm
  ];
}
