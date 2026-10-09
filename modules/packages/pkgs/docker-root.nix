{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.dockerRoot.enable = lib.options.mkEnableOption "rootful Docker package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.dockerRoot.enable {
    assertions = [
      {
        assertion = !config.cri.packages.pkgs.docker.enable;
        message = ''
          cri.packages.pkgs.docker (rootless) and cri.packages.pkgs.dockerRoot
          (rootful) both configure virtualisation.docker, enable only one of
          them.
        '';
      }
    ];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    virtualisation.docker.enable = true;

    # Our users come from LDAP, so they cannot be members of the local `docker`
    # group. We used to add the group at login time with pam_group, but that
    # does not work anymore, hence we open the socket to every local user
    # instead. This is equivalent to the `*;*;*;Al0000-2400;docker` pam_group
    # rule we had before: any user of the machine could already talk to the
    # daemon.
    systemd.sockets.docker.socketConfig.SocketMode = lib.mkForce "0666";
  };
}
