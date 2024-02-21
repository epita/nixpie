{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cri.nswrappers;
in
{
  options = {
    cri.nswrappers = {
      enable = mkEnableOption "wrappers for ip netns commands";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ethtool
      libpcap
      nswrappers
      wireshark
    ];

    security.sudo.extraRules = [{
      users = [ "ALL" ];
      commands = [
        { command = "/run/current-system/sw/bin/ns-init"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ns-add-if"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ns-exec"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ns-del-if"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ns-destroy"; options = [ "NOPASSWD" ]; }
      ];
    }];
  };
}
