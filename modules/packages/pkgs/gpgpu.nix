{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.gpgpu.enable = lib.options.mkEnableOption "gpgpu CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.gpgpu.enable {
    environment.systemPackages = with pkgs; [
      # OpenCV
      clinfo
      ocl-icd
      opencl-headers
      mesa

      # CUDA
      binutils
      cudaPackages.cudatoolkit
      cudaPackages.nsight_systems
      cudaPackages.nsight_compute
      freeglut
      gperf
      gitRepo
      libGL
      libGLU
      linuxPackages.nvidia_x11
      m4
      # ncurses5 # makes system-path builder go into an infinite loop
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXmu
      xorg.libXrandr
      xorg.libXtst
      xorg.libXv
      zlib

      jre8
      jdk8

      # Misc
      boost
      freeimage
      glfw
      hashcat
      hashcat-utils
    ];
  };
}
