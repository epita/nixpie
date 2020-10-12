{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.sound = {
      enable = mkEnableOption "Whether to enable ALSA sound.";
    };
  };

  config = mkIf config.cri.sound.enable {
    sound.enable = true;

    hardware = {
      pulseaudio = {
        enable = true;
        package = mkIf config.cri.bluetooth.enable pkgs.pulseaudioFull;
        extraModules = optional config.cri.bluetooth.enable pkgs.pulseaudio-modules-bt;
      };
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
      pa_applet
      paprefs
    ];
  };
}
