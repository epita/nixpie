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
      # GNS3 talks to the system-wide Docker socket, it cannot use a rootless
      # daemon.
      dockerRoot.enable = true;
      net.enable = true;
    };
  };

  #environment.systemPackages = with pkgs; [ ciscoPacketTracer8 ];

  cri.nswrappers.enable = true;
}
