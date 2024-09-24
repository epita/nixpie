{ config, lib, pkgs, ... }:

let
  run_image = pkgs.writeShellScriptBin "run_image" ''
    IMAGE_NAME=$1
    LATEST_TAG=$2

    # Hack to be able to chown those files in the container
    cat $HOME/afs/.confs/gitconfig > $HOME/tty_gitconfig 
    ! [ -d $HOME/tty_sh ] && mkdir $HOME/tty_ssh
    for f in $HOME/afs/.confs/ssh/*; do
      name=$(basename "$f")
      cat $f > $HOME/tty_ssh/$name
    done

    # Run the container
    KRB5CCACHE=$(klist | head -1 | cut -d : -f 3)
    podman run -it -v $KRB5CCACHE:/tmp/krb5cc_1000                              \
                   -v $HOME/tty_gitconfig:/home/student/.gitconfig:copy,U       \
                   -v $HOME/tty_ssh:/home/student/.ssh/:copy,U                  \
                   $IMAGE_NAME:$LATEST_TAG
  '';

  aria2c_hook = pkgs.writeShellScriptBin "aria2c_hook" ''
    set -ux

    GID=$1
    FILE_NUMBER=$2
    FILE_PATH=$3

    IMAGE_NAME=tty-env

    podman image import "$FILE_PATH" "$IMAGE_NAME"
  
    LATEST_TAG=$(curl $LATEST_TAG_URL)
    run_image "$IMAGE_NAME" "$LATEST_TAG"
  '';

  tty_launch = pkgs.writeShellScriptBin "tty_launch" ''
    #!/bin/sh

    set -ux

    IMAGE_NAME=tty-env

    IMAGE_TAR_NAME=$IMAGE_NAME.tar.gz
    TORRENT_NAME=$IMAGE_TAR_NAME.torrent

    S3_BUCKET=https://s3.cri.epita.fr/acu-cnix-tty-activity
    LATEST_TAG_URL=$S3_BUCKET/latest_tag
    TORRENT_URL=$S3_BUCKET/$TORRENT_NAME

    LATEST_TAG=$(curl $LATEST_TAG_URL)

    # If the image with the fetched tag is absent, download the torrent file
    podman image exists $IMAGE_NAME:$LATEST_TAG > /dev/null 2>&1 
    if [ $? -ne 0 ]; then
      # ! [ -d /srv/torrent/ ] && mkdir /srv/torrent
      # cd /srv/torrent

      curl $TORRENT_URL --output $TORRENT_NAME
      ${pkgs.aria2}/bin/aria2c --on-download-complete aria2c_hook \
                               --enable-dht=false       \
                               --enable-dht6=false      \
                               --seed-ratio=0           \
                               "$TORRENT_NAME"&
    else
      run_image "$IMAGE_NAME" "$LATEST_TAG"
    fi
    # TODO:
    # Make sure to update /srv/torrent/aria2_seedlist.txt to include your file. 
    # Make sure you don't mess with the rest of the file as it is used to seed PIE squashfs. 
    # Maybe systemctl restart aria2, I don't remember if the file is hot reloaded.
  '';
in
{
  # Define the shell script to generate the static /etc/issue file
  environment.etc."issue".text = lib.strings.concatStrings [
    (builtins.readFile (pkgs.runCommand "cnix-tty-issue" {} (builtins.readFile ./tty-issue.sh)))
    "\n${config.system.nixos.distroName} ${config.system.nixos.label} (\\m) - \\l\n\n"
  ];

  cri = {
    packages.pkgs.podman.enable = true;

    aria2.enable = true;
  };

  netboot.enable = true;

  environment.systemPackages = [
    tty_launch
    run_image
    aria2c_hook
  ];
}

