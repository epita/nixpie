{ pkgs, ... }:

{
  cri.programs.packageBundles.gpgpu = with pkgs; [
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
}
