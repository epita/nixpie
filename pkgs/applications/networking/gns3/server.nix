{ gns3-server }:

# TODO: remove me when issue nixpkgs#252569 is resolved
gns3-server.overrideAttrs (old: rec {
  postInstall = (old.postInstall or "") + ''
    chmod +x $out/lib/python3.10/site-packages/gns3server/compute/docker/resources/*.sh
    chmod +x $out/lib/python3.10/site-packages/gns3server/compute/docker/resources/bin/*
  '';
})
