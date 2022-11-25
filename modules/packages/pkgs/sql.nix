{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.sql.enable = lib.options.mkEnableOption "dev SQL CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.sql.enable {
    environment.systemPackages = with pkgs; [
      jetbrains.datagrip
      postgresql
    ];

    environment.pathsToLink = [
      "/share/postgresql"
    ];
  };
}
