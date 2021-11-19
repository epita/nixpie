{ config, lib, ... }:

with lib;

{
  networking = {
    hostName = mkForce "machine";
    useDHCP = mkForce false;
  };

  system.name = mkForce config.networking.hostName;

  cri = {
    machine-state.enable = mkForce false;
    salt.enable = mkForce false;
  };

  # Disabled in tests by default in NixOS, but we enable it in
  # profiles/core so it conflicts. Let's just get rid of it, we don't
  # test it anyway
  documentation = {
    enable = mkForce false;
  };
}
