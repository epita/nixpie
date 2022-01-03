{ pkgs, ... }:

{
  cri.programs.packageBundles.devSQL = with pkgs; [
    dbeaver
    jetbrains.datagrip
    pgadmin
    postgresql
  ];
}
