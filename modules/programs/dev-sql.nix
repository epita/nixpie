{ pkgs, ... }:

{
  cri.programs.devSQL = with pkgs; [
    dbeaver
    pgadmin
    postgresql
  ];
}
