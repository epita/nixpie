{ config, pkgs, ... }:
{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Summer Program";

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idProduct}=="7523", ATTRS{idVendor}=="1a86", SYMLINK+="espcam", GROUP="users"
  '';

  cri = {
    xfce.enable = true;

    packages.pkgs = {
      dev.enable = true;
      docker.enable = true;
      net.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    arduino
  ];
}


