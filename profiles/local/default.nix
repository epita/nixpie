{ lib, ... }:

with lib;

{
  netboot.enable = mkForce false;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };
  swapDevices = [
    { device = "/dev/disk/by-label/nixos-swap"; }
  ];
}
