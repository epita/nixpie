{ pkgs, ... }:

{
  cri.programs.dev = with pkgs; [
    dosbox
    nasm
  ];
}
