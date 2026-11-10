{ config, lib, pkgs, ... }:

with lib;

let
  serverDockerSrc = {
    imageName = "registry.cri.epita.fr/ing/activites/net1-appliances/server";
    imageDigest = "sha256:b69c155c43953a96cbcd9886fc635980a6ef11aed8cef1339d2a381b6de5e1de";
    hash = "sha256-K8RK1ap3BX6emIXrn8unpm0wEA3PO1P05Syo/D1DDo4=";
    finalImageName = "registry.cri.epita.fr/ing/activites/net1-appliances/server";
    finalImageTag = "2.0";
  };
  routerDockerSrc = {
    imageName = "registry.cri.epita.fr/ing/activites/net1-appliances/router";
    imageDigest = "sha256:85a125eb54649ae993575206b30d82fbbb3e862775c3faccaf84fcfa8a0021cf";
    hash = "sha256-VjP3bH9oL5z93yXWB6ONyenddy76hRHcI88Mz278emE=";
    finalImageName = "registry.cri.epita.fr/ing/activites/net1-appliances/router";
    finalImageTag = "2.0";
  };
  computerDockerSrc = {
    imageName = "registry.cri.epita.fr/ing/activites/net1-appliances/computer";
    imageDigest = "sha256:e64f643a2a94774368504894f48f2a99d0a7273878834b8b7f80e9187d367aad";
    hash = "sha256-dmCRDLZyKfGPFlJJTtnLZy3oMFfyhjMt+bGwzwlYKSY=";
    finalImageName = "registry.cri.epita.fr/ing/activites/net1-appliances/computer";
    finalImageTag = "2.0";
  };

  preloadedImages = map pkgs.dockerTools.pullImage [
    serverDockerSrc
    computerDockerSrc
    routerDockerSrc
  ];
in
{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-net.nix
  ];

  environment.systemPackages = with pkgs; [ ];

  # Docker is rootless here, so every user runs its own daemon with its own
  # image store: the images have to be loaded in the user instance, once the
  # user daemon is up, and not system-wide.
  systemd.user.services.docker-preload = {
    description = "Preload NET appliance images in the rootless Docker daemon";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "default.target" ];
    path = [ config.virtualisation.docker.rootless.package ];
    # Same condition as the rootless daemon unit, as root uses the rootful one.
    unitConfig.ConditionUser = "!root";
    environment.DOCKER_HOST = "unix://%t/docker.sock";
    script = concatMapStringsSep "\n" (image: "docker load -i ${image}") preloadedImages;
    serviceConfig = {
      RemainAfterExit = true;
      Type = "oneshot";
    };
  };

  cri.sddm.title = lib.mkForce "Exam NET";
}
