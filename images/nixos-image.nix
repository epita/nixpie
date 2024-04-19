{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS IMAGE";
  cri.packages = {
    pkgs = {
      dev.enable = true;
      opengl.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    blender
  ];
}
