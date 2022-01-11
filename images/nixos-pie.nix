{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS PIE";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev devSQL devThl devJava ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev devThl ];

  cri.nswrappers.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };

  users = {
    users.docker = {
      subUidRanges = [{
        count = 100000;
        startUid = 65536;
      }];
      subGidRanges = [{
        count = 100000;
        startUid = 65536;
      }];
    };
    groups.docker.gid = config.ids.gids.docker;
  };

  virtualisation.docker.enable = true;

  system.services.docker = {
    serviceConfig = {
      User = "docker";
      Group = "docker";
      ExecStart = [
        ""
        ''
          ${dockerEngine}/docker-rootless.sh
        ''
      ];
    };
    path = [ pkgs.rootlesskit ];
  };

  systemd.sockets.docker.socketConfig = {
    SocketMode = "0666";
    SocketGroup = "15000";
  };
}

# see https://github.com/docker/engine/blob/master/contrib/dockerd-rootless-setuptool.sh
