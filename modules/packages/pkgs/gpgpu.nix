{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.gpgpu.enable = lib.options.mkEnableOption "gpgpu CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.gpgpu.enable {
    hardware.graphics.enable = true;
    environment.sessionVariables.LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];

    environment.systemPackages = with pkgs; [
      # OpenCV
      clinfo
      ocl-icd
      opencl-headers
      mesa

      # CUDA
      binutils
      cudaPackages.cudatoolkit
      cudaPackages.cuda_nvprof
      (cudaPackages.nsight_systems.overrideAttrs (final: prev: {
        buildInputs = prev.buildInputs ++ [ boost178 e2fsprogs ];
      }))
      #cudaPackages.nsight_compute #FIXME
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
