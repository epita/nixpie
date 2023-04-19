{ config, lib, pkgs, ... }:

let
  compose = pkgs.podman-compose;
  docker-compose-alias = pkgs.runCommand "${compose.pname}-docker-compose-alias-${compose.version}"
    {
      inherit (compose) meta;
    } ''
    mkdir -p $out/bin
    ln -s ${compose}/bin/podman-compose $out/bin/docker-compose
  '';
in
{
  options = {
    cri.packages.pkgs.podman.enable = lib.options.mkEnableOption "podman CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.podman.enable
    {
      virtualisation = {
        podman = {
          enable = true;
          dockerCompat = true;

          # By default, containers in the same network can't reach each others via their name.
          # We need to enable the 'dnsname' for this in the default network, on whom every other network
          # is based on.
          defaultNetwork.dnsname.enable = true;
        };

        containers = {
          # Podman stores images in the user's home, which is a tmpfs on regular NixPIE images.
          # But tmpfs does not support some xattrs, such as those required to make a folder 'opaque'
          # which is used by a lot of images.
          # Using fuse-overlayfs fixes this (but trades performances for that).
          storage.settings = {
            storage.driver = "overlay";
            storage.options.overlay.mount_program = "${lib.getExe pkgs.fuse-overlayfs}";
          };

          # By default, podman prompts the user to chose a registry everytime an image is being pulled.
          registries.search = [ "docker.io" ];
        };
      };

      environment = {
        # For some reason, podman does not read the default storage.conf file without this variable.
        variables.CONTAINERS_STORAGE_CONF = "/etc/containers/storage.conf";

        systemPackages = [
          compose
          docker-compose-alias
        ];
      };
    };
}
