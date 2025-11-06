{ config, pkgs, lib, ... }:

{
  imports = [ ../profiles/graphical ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SSSE";

  cri.packages = {
    python.core.enable = true;
    python.ssse.enable = true;
    ocaml.ssse.enable = true;
    pkgs = {
      dev.enable = true;
      podman.enable = true; # FORGE #65303
      js.enable = true;
      ocaml.enable = true;
      ssse.enable = true;
      libvirt.enable = true;
      libvirt.enableDiskPartition = true;
    };
  };
}
