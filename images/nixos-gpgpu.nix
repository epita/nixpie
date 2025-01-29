{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS GPGPU";
  cri.sshd.allowUsers = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

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

  cri.packages = {
    pkgs = {
      dev.enable = true;
      gpgpu.enable = true;
      opengl.enable = true;
    };
  };

  environment.variables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
  };

  # On SSH OpenStack GPU instances, students tend to use all the memory and the
  # system ends up unresponsive. This allows systemd-oomd to take action on
  # student's processes before the memory is full.
  systemd.oomd.enableUserSlices = true;

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
      ];
      shellHook = with pkgs;'' + "''" + ''
    export CUDA_PATH=''${pkgs.cudaPackages.cudatoolkit}
    export LD_LIBRARY_PATH=''${linuxPackages.nvidia_x11}/lib:''${ncurses5}/lib:''${libkrb5}/lib:$LD_LIBRARY_PATH
    export EXTRA_LDFLAGS="-L/lib -L''${linuxPackages.nvidia_x11}/lib $EXTRA_LDFLAGS"
    export EXTRA_CCFLAGS="-I/usr/include $EXTRA_CCFLAGS"
  '' + "''" + '';
    }
  '';
}
