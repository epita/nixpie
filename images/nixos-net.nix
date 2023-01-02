{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS NET";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      net.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ ciscoPacketTracer8 ];

  cri.nswrappers.enable = true;
}
