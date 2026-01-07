{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.java.enable = lib.options.mkEnableOption "dev Java CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.java.enable {
    environment.systemPackages = with pkgs; [
      jetbrains.idea
      maven
    ];

    programs.java = {
      enable = true;
      package = pkgs.jdk;
    };
  };
}
