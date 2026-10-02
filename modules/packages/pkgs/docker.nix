{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.docker.enable = lib.options.mkEnableOption "Docker package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.docker.enable {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    # Since NixOS 26.05 and for an unknown reason this is required because the
    # module does not seem to be loaded automatically. Possibly an upstream bug,
    # but we have to enforce that here for now.
    boot.kernelModules = [ "tun" ];

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
