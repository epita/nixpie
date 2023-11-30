{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.ssie.enable =
      lib.options.mkEnableOption "dev SSIE CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.ssie.enable {
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
      libgcc
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
