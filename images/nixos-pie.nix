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
      js.enable = true;
      podman.enable = true;
      prolog.enable = true;
      prpa.enable = true;
      spider.enable = true;
      sql.enable = true;
      thl.enable = true;
      tiger.enable = true;
    };
  };

  cri.nswrappers.enable = true;
}
