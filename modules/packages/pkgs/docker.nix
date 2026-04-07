{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.docker.enable = lib.options.mkEnableOption "Docker package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.docker.enable {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
