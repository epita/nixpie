{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.ssse.enable =
      lib.options.mkEnableOption "dev SSSE CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.ssse.enable {
    cri.packages.python.ssse.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      arduino
      julia
      kicad-unstable
      liberio
      mosquitto
      nodePackages.node-red
      platformio-core
      sfml
      asio
      jsoncpp
      gnuplot
      tig
      ngspice
      pulseview
      sigrok-cli
      vscodium
      tlaplusToolbox
    ];

    environment.etc."security/group.conf".text = ''
      *;*;*;Al0000-2400;dialout
    '';
    security.pam.services.sddm.text = lib.mkBefore ''
      auth  required                    pam_group.so
    '';
  };
}
