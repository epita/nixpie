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

      nixpie = import (builtins.fetchTarball "https://gitlab.cri.epita.fr/cri/infrastructure/nixpie/-/archive/master/nixpie-master.tar.gz");

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

  systemd.services.cuda-memcheck-init =
    let
      cudaSrc = pkgs.writeText "vector_add_grid.cu" ''
        #include <stdio.h>
        #include <stdlib.h>
        #include <math.h>
        #include <assert.h>
        #include <cuda.h>
        #include <cuda_runtime.h>

        #define N 10000000
        #define MAX_ERR 1e-6

        __global__ void vector_add(float *out, float *a, float *b, int n) {
            int tid = blockIdx.x * blockDim.x + threadIdx.x;

            // Handling arbitrary vector size
            if (tid < n){
                out[tid] = a[tid] + b[tid];
            }
        }

        int main(){
            float *a, *b, *out;
            float *d_a, *d_b, *d_out;

            // Allocate host memory
            a   = (float*)malloc(sizeof(float) * N);
            b   = (float*)malloc(sizeof(float) * N);
            out = (float*)malloc(sizeof(float) * N);

            // Initialize host arrays
            for(int i = 0; i < N; i++){
                a[i] = 1.0f;
                b[i] = 2.0f;
            }

            // Allocate device memory
            cudaMalloc((void**)&d_a, sizeof(float) * N);
            cudaMalloc((void**)&d_b, sizeof(float) * N);
            cudaMalloc((void**)&d_out, sizeof(float) * N);

            // Transfer data from host to device memory
            cudaMemcpy(d_a, a, sizeof(float) * N, cudaMemcpyHostToDevice);
            cudaMemcpy(d_b, b, sizeof(float) * N, cudaMemcpyHostToDevice);


            // Executing kernel
            int block_size = 256;
            int grid_size = ((N + block_size) / block_size);
            vector_add<<<grid_size,block_size>>>(d_out, d_a, d_b, N);

            // Transfer data back to host memory
            cudaMemcpy(out, d_out, sizeof(float) * N, cudaMemcpyDeviceToHost);

            // Verification
            for(int i = 0; i < N; i++){
                assert(fabs(out[i] - a[i] - b[i]) < MAX_ERR);
            }

            printf("PASSED\n");

            // Deallocate device memory
            cudaFree(d_a);
            cudaFree(d_b);
            cudaFree(d_out);

            // Deallocate host memory
            free(a);
            free(b);
            free(out);
        }
      '';
    in
    {
      description = "Run cuda-memcheck once as root.";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
      };
      environment = config.environment.sessionVariables;
      script = ''
        ${config.nix.package}/bin/nix-shell \
          /etc/nixos-gpgpu/shell.nix \
          --run 'nvcc ${cudaSrc} -o /tmp/vector_add_grid && cuda-memcheck /tmp/vector_add_grid'
      '';
    };
}
