{ config, pkgs, lib, ... }:

{
  imports = [ ../profiles/graphical ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SSIE";

  cri.packages = {
    python.core.enable = true;
    ocaml.ssie.enable = true;
    pkgs = {
      dev.enable = true;
      js.enable = true;
      ocaml.enable = true;
      ssie.enable = true;
    };
  };
}
