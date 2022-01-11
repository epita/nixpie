{ pkgs, ... }:

{
  cri.programs.packageBundles.devSQL = with pkgs; [
    jetbrains.datagrip
    postgresql
  ];
}
