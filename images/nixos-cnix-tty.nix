{ config, lib, pkgs, ... }:

let
  aria2_restart = pkgs.writeShellScriptBin "aria2_restart" ''
    systemctl restart aria2 
  '';

  tty_launch = pkgs.writeShellScriptBin "tty_launch" ''
    set -eux

    IMAGE_NAME=tty-env

    IMAGE_TAR_NAME=$IMAGE_NAME.tar.gz
    TORRENT_NAME=$IMAGE_TAR_NAME.torrent

    S3_BUCKET=https://s3.cri.epita.fr/acu-cnix-tty-activity
    LATEST_TAG_URL=$S3_BUCKET/latest_tag
    TORRENT_URL=$S3_BUCKET/$TORRENT_NAME

    LATEST_TAG=$(curl --fail "$LATEST_TAG_URL")

    # If the image with the fetched tag is absent, download the torrent file
    set +e
    podman image exists $IMAGE_NAME:$LATEST_TAG > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      # This cannot be done, as the script does not have enough permissions to
      # write in the /srv/torrent directory somehow.
      # cd /srv/torrent
      set -e

      curl --fail "$TORRENT_URL" --output "$TORRENT_NAME"

      /run/wrappers/bin/aria2_restart

      ${pkgs.aria2}/bin/aria2c --enable-dht=false       \
                               --enable-dht6=false      \
                               --seed-ratio=0           \
                               --seed-time=0            \
                               "$TORRENT_NAME"

      podman load -i "$IMAGE_TAR_NAME"
    fi
    set -e

    # TODO:
    # Make sure to update /srv/torrent/aria2_seedlist.txt to include your file. 
    # Make sure you don't mess with the rest of the file as it is used to seed PIE squashfs. 
    # Maybe systemctl restart aria2, I don't remember if the file is hot reloaded.

    # Hack to be able to chown those files in the container
    cat $HOME/afs/.confs/gitconfig > $HOME/tty_gitconfig 
    [ -d $HOME/tty_sh ] && mkdir $HOME/tty_ssh
    for f in $HOME/afs/.confs/ssh/*; do
      name=$(basename "$f")
      cat $f > $HOME/tty_ssh/$name
    done

    # Run the container
    KRB5CCACHE=$(klist | head -1 | cut -d : -f 3)
    podman run -it -v $KRB5CCACHE:/tmp/krb5cc_1000                              \
                   -v $HOME/tty_gitconfig:/home/student/.gitconfig:copy,U       \
                   -v $HOME/tty_ssh:/home/student/.ssh/:copy,U                  \
                   localhost/tty_$IMAGE_NAME:$LATEST_TAG
  '';
in
{
  # Define the shell script to generate the static /etc/issue file
  environment.etc."issue".text = lib.strings.concatStrings [
    (builtins.readFile (pkgs.runCommand "cnix-tty-issue" {} (builtins.readFile ./tty-issue.sh)))
    "\n${config.system.nixos.distroName} ${config.system.nixos.label} (\\m) - \\l\n\n"
  ];

  # FIXME: To delete later
  systemd.services.mount = {
    description = "mount of /srv/torrent on local mount";

    after = [ "aria2.target" ];

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
    };

    script = ''
      mkdir -p /srv/torrent
      touch /srv/torrent/aria2_seedlist.txt

      {
        echo "${config.netboot.torrent.mountPoint}/tty-env.tar.gz.torrent"
        echo " index-out=1=${config.netboot.torrent.mountPoint}/tty-env.tar.gz.torrent"
        echo " dir=${config.netboot.torrent.mountPoint}"
        echo " check-integrity=true"
      } >> ${config.netboot.torrent.mountPoint}/aria2_seedlist.txt
      
      systemctl restart aria2
    '';
  };

  security.wrappers = {
    aria2_restart = {
      setuid = true;
      owner = "root";
      group = "root";
      permissions = "u+rwx,g+rx,o+rx";
      source = "${aria2_restart}";
    };
  };

  cri = {
    packages.pkgs.podman.enable = true;

    aria2.enable = true;
  };

  netboot.enable = true;

  environment.systemPackages = [
    tty_launch
  ];
}

