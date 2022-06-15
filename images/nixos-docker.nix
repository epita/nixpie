{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Docker";

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  environment.etc."security/group.conf".text = ''
    *;*;*;Al0000-2400;docker
  '';
  security.pam.services.sddm.text = lib.mkBefore ''
    auth  required                    pam_group.so
  '';
}
