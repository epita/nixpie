{ gns3-server, ... }:

gns3-server.overrideAttrs (old: {
  # Let DOCKER_HOST override the system-wide Docker socket, which is required
  # to reach a rootless Docker daemon.
  patches = (old.patches or [ ]) ++ [
    ./docker-host-env-var.patch
  ];
})
