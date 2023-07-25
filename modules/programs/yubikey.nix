{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.yubikey = {
      enable = mkEnableOption "Enable yubikey-related tools";
    };
  };

  config = mkIf config.cri.yubikey.enable {
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      yubioath-flutter
    ];
  };
}
