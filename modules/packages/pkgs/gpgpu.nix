{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.gpgpu.enable = lib.options.mkEnableOption "gpgpu CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.gpgpu.enable {
    security.wrappers.nvprof = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.cudatoolkit}/bin/nvprof";
    };

    environment.systemPackages = with pkgs; [
      # OpenCV
      clinfo
      ocl-icd
      opencl-headers
      mesa

      # CUDA
      binutils
      cudatoolkit
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
