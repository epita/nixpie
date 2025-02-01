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
      js.enable = true;
      ocaml.enable = true;
      ssse.enable = true;
      libvirt.enable = true;
      libvirt.enableDiskPartition = true;
    };
  };
}
