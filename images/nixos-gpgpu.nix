{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS GPGPU";
  cri.sshd.allowUsers = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_RestrictProfilingToAdminUsers=0 NVreg_DeviceFileMode=0666
  '';

  boot.kernelParams = [
    "nomodeset"
  ];

  environment.pathsToLink = [
    "/nvvm"
    "/nvvmx"
    "/targets"
  ];

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    gpgpu
    opengl
  ];

  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev ];

  environment.variables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
  };

  environment.etc."nixos-gpgpu/shell.nix".text = ''
    let
      system = "x86_64-linux";

      nixpie = import <nixpie>;

      inherit (nixpie.inputs.nixpkgs) lib;
      inherit (lib) attrValues;

      pkgs = import nixpie.inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = (attrValues nixpie.overlays) ++ [ nixpie.overrides.''${system} ];
      };
    in
    pkgs.mkShell {
      name = "cuda-env-shell";
      buildInputs = with pkgs; [
        git gitRepo gnupg autoconf curl
        procps gnumake utillinux m4 gperf unzip cmake
        linuxPackages.nvidia_x11
        libGLU libGL
        xorg.libXi xorg.libXmu freeglut
        xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib pngpp tbb
        ncurses5 stdenv.cc binutils
        (cudatoolkit.override {
          gcc = stdenv.cc;
        })
      ];
      shellHook = with pkgs;'' + "''" + ''
    export CUDA_PATH=''${pkgs.cudatoolkit}
    export PATH=$CUDA_PATH/nsight_compute:$CUDA_PATH/nsight_systems/host-linux-x64:$PATH
    export LD_LIBRARY_PATH=''${linuxPackages.nvidia_x11}/lib:''${ncurses5}/lib:''${libkrb5}/lib:$LD_LIBRARY_PATH
    export EXTRA_LDFLAGS="-L/lib -L''${linuxPackages.nvidia_x11}/lib $EXTRA_LDFLAGS"
    export EXTRA_CCFLAGS="-I/usr/include $EXTRA_CCFLAGS"
  '' + "''" + '';
    }
  '';
}
