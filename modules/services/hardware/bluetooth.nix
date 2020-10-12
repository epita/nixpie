{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.bluetooth = {
      enable = mkEnableOption "Whether to enable bluetooth.";
    };
  };

  config = mkIf config.cri.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
    };

    services.blueman.enable = true;

    environment.systemPackages = with pkgs; [
      bluez-tools
      blueberry
    ];
  };
}
