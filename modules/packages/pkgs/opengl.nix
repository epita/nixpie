{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.opengl.enable = lib.options.mkEnableOption "OpenGL CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.opengl.enable {
    environment.systemPackages = with pkgs; [
      blender
      freeglut
      glew
    ];
  };
}
