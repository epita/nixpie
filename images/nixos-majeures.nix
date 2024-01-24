{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Majeures";

  cri.packages = {
    pkgs = {
      coq.enable = true;
      info9.enable = true;
      libvirt.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    burpsuite # ticket #41353, GISTRE SECSYS
  ];
}
