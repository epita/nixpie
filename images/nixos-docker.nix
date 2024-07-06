{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  system.nixos.securityClass = "misc";

  cri.packages = {
    pkgs = {
      docker.enable = true;
    };
  };

  netboot.enable = true;
  cri.sddm.title = "NixOS Docker";

}
