{ pkgs, ... }:

{
  cri.programs.packageBundles.devRust = with pkgs; [
    cargo
    rustc
    rustup
  ];
}
