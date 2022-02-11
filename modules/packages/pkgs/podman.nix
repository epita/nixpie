{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.podman.enable = lib.options.mkEnableOption "podman CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.podman.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
