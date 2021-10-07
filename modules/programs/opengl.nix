{ pkgs, ... }:

{
  cri.programs.packageBundles.opengl = with pkgs; [
    blender
    freeglut
    glew
  ];
}
