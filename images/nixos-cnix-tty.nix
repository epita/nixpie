{ config, lib, pkgs, ... }:

let
  tty_launch = pkgs.writeShellScriptBin "tty_launch" ''
    #!/bin/sh

    REGISTRY=registry.cri.epita.fr/ing/assistants/subjects/piscine/exercises-misc/tty:latest
    CREDS="--authfile=/home/theo.gardet/afs/auth.json" # FIXME: This should not go into production
    # We systematically clean the remnants of the previous image to avoid the
    # command failing because of a lack of space on the device.
    # FIXME: This still creates a lot of <none> images.
    podman stop --all
    podman container rm --all
    podman rmi "$REGISTRY"
    podman pull $CREDS "$REGISTRY"

    # Hack to be able to chown those files in the container
    cat $HOME/afs/.confs/gitconfig > $HOME/tty_gitconfig 
    mkdir $HOME/tty_ssh
    for f in $HOME/afs/.confs/ssh/*; do
      name=$(basename "$f")
      cat $f > $HOME/tty_ssh/$name
    done

    podman run -it -v /tmp:/tmp -v $HOME/tty_gitconfig:/home/student/.gitconfig:copy,U -v $HOME/tty_ssh:/home/student/.ssh/:copy,U $CREDS "$REGISTRY"
  '';
in
{
  # Define the shell script to generate the static /etc/issue file
  environment.etc."issue".text = lib.strings.concatStrings [
    (builtins.readFile ./tty-issue)
    "\n${config.system.nixos.distroName} ${config.system.nixos.label} (\\m) - \\l\n\n"
  ];

  cri.packages.pkgs.podman.enable = true;

  environment.systemPackages = [
    tty_launch
  ];
}

