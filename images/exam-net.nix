{ config, lib, pkgs, ... }:

with lib;

let
  serverDockerSrc = {
    imageName = "registry.cri.epita.fr/ing/activites/net1-appliances/server";
    imageDigest = "sha256:e23c6edef7c6d36da90b154c7c022e24a2d705bd109bb2c261c81039cd5ba9f8";
    sha256 = "0vr97hygsnz6q0vbvglhyym9k0q6jn9x0f20m60ggnl0dl0gkvhw";
    finalImageName = "registry.cri.epita.fr/ing/activites/net1-appliances/server";
    finalImageTag = "1.0";
  };
  routerDockerSrc = {
    imageName = "registry.cri.epita.fr/ing/activites/net1-appliances/router";
    imageDigest = "sha256:87eec82d42f0b68df0e2947ef099d25baef9efe0e7779dcb28bb18a10f87d195";
    sha256 = "08vyrza6g3xhyfv0pmdxx3n3pn2gd1x33cvi7bfzc7d6fqygl5qp";
    finalImageName = "registry.cri.epita.fr/ing/activites/net1-appliances/router";
    finalImageTag = "1.0";
  };
  computerDockerSrc = {
    imageName = "registry.cri.epita.fr/ing/activites/net1-appliances/computer";
    imageDigest = "sha256:70f24801564b6e4aa919c60d1cf731b6c2ec54e7f8bf526b2f218064a3a32856";
    sha256 = "1cvai0san4n5pcamhllclxi1m0l82v5walbxrv9mp8qkcwjk1ap7";
    finalImageName = "registry.cri.epita.fr/ing/activites/net1-appliances/computer";
    finalImageTag = "1.0";
  };
in
{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-net.nix
  ];

  environment.systemPackages = with pkgs; [ ];
  systemd.services.docker-preload = {
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ config.virtualisation.docker.package ];
    script = ''
      docker load -i ${pkgs.dockerTools.pullImage serverDockerSrc}
      docker load -i ${pkgs.dockerTools.pullImage computerDockerSrc}
      docker load -i ${pkgs.dockerTools.pullImage routerDockerSrc}
    '';
    serviceConfig = {
      RemainAfterExit = true;
      Type = "oneshot";
    };
  };

  cri.sddm.title = lib.mkForce "Exam NET";
}
