{ pkgs, ... }:

{
  cri.programs.packageBundles.devSQL = with pkgs; [
    dbeaver
    pgadmin
    postgresql
  ];
}
