{ lib, ... }:

with lib;

{
  netboot.enable = mkForce false;

  networking = {
    networkmanager.enable = mkForce true;
    hostName = mkForce "nixos";
    useDHCP = mkForce false;
  };

  programs.nm-applet.enable = true;

  cri = {
    afs.enable = false;
    krb5.enable = false;
    ldap.enable = false;

    users.checkEpitaUserAllowed = false;
  };

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
