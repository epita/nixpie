{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Test.";

  environment.systemPackages = with pkgs; [
    linuxPackages.nvidia_x11
  ];

  services.xserver.videoDrivers = lib.mkBefore [ "nvidia" ];
  hardware.opengl.extraPackages = with pkgs; [ mesa.drivers ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_RestrictProfilingToAdminUsers=0 NVreg_DeviceFileMode=0666
  '';

  boot.kernelParams = [
    "nomodeset"
  ];

  cri.packages = {
    pkgs = {
      dev.enable = true;
    };
  };
}
