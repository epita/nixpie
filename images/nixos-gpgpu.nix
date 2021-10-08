{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS GPGPU";

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_RestrictProfilingToAdminUsers=0
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
}
