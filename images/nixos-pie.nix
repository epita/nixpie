{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS PIE";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      java.enable = true;
      podman.enable = true;
      sql.enable = true;
      thl.enable = true;
    };
  };

  cri.nswrappers.enable = true;
}
