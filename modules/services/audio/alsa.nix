{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.sound = {
      enable = mkEnableOption "Whether to enable ALSA sound.";
    };
  };

  config = mkIf config.cri.sound.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
      pa_applet
      paprefs
    ];
  };
}
