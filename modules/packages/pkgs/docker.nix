{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.docker.enable = lib.options.mkEnableOption "Docker package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.docker.enable {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    virtualisation.docker.enable = true;

    environment.etc."security/group.conf".text = ''
      *;*;*;Al0000-2400;docker
    '';
    security.pam.services.sddm.text = lib.mkBefore ''
      auth  required                    pam_group.so
    '';
  };
}
