{ pkgs, ... }:

{
  cri.programs.devRust = with pkgs; [
    cargo
    rustc
    rustup
  ];
}
