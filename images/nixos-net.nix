{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  system.nixos.securityClass = "misc";

  netboot.enable = true;
  cri.sddm.title = "NixOS NET";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      docker.enable = true;
      net.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ ciscoPacketTracer8 ];

  cri.nswrappers.enable = true;
}
