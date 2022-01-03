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
      groups = [ 15000 ]; # students
      commands = [
        { command = "${pkgs.nswrappers}/bin/ns-init"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nswrappers}/bin/ns-add-if"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nswrappers}/bin/ns-exec"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nswrappers}/bin/ns-del-if"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.nswrappers}/bin/ns-destroy"; options = [ "NOPASSWD" ]; }
      ];
    }];
  };
}
