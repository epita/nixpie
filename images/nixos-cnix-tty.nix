{ config, lib, pkgs, ... }:

let
  imageName = "tty-env";
  imageFilename = "${imageName}.tar.gz";
  torrentFilename = "${imageFilename}.torrent";
  s3Bucket = "https://s3.cri.epita.fr/acu-cnix-tty-activity";
  torrentDir = config.netboot.torrent.mountPoint;

  downloadTtyImage = pkgs.writeShellScript "download_tty_image.sh" ''
    set -eu

    echo "Fetching torrent file"
    ${pkgs.curl}/bin/curl --fail "${s3Bucket}/${torrentFilename}" --output "${torrentDir}/${torrentFilename}"

    echo "Fetching image using torrent"
    ${pkgs.aria2}/bin/aria2c --enable-dht=false       \
                             --enable-dht6=false      \
                             --seed-ratio=0           \
                             --seed-time=0            \
                             --dir="${torrentDir}" --index-out=1="${imageFilename}" \
                             "${torrentDir}/${torrentFilename}"

    echo "Restarting aria2 for seeding"
    ${pkgs.systemd}/bin/systemctl restart aria2
  '';

  setuidDownloadWrapperSrc = pkgs.writeText "cnixtty-downloader-wrapper.c" ''
    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/types.h>
    #include <unistd.h>

    int main()
    {
        setuid(0);
        return system("${downloadTtyImage}");
    }
  '';

  setuidDownloadWrapper = pkgs.runCommandCC "download_tty_image" { } ''
    gcc -o "$out" "${setuidDownloadWrapperSrc}"
  '';

  tty_launch = pkgs.writeShellScriptBin "tty_launch" ''
    set -eu

    echo "Fetching latest image tag"
    LATEST_TAG=$(${pkgs.curl}/bin/curl --fail "${s3Bucket}/latest_tag")
    echo "Latest tag is $LATEST_TAG"

    # If the image with the fetched tag is absent, download the torrent file
    if ! podman image exists "${imageName}:$LATEST_TAG" > /dev/null 2>&1; then
      echo "Image is missing from disk, downloading."
      /run/wrappers/bin/download_tty_image

      echo "Image finished downloading, loading in podman"
      podman load -i "${torrentDir}/${imageFilename}"
    fi

    # Hack to be able to chown those files in the container
    cat $HOME/afs/.confs/gitconfig > $HOME/tty_gitconfig 
    [ -d $HOME/tty_sh ] || mkdir $HOME/tty_ssh
    for f in $HOME/afs/.confs/ssh/*; do
      name=$(basename "$f")
      cat $f > $HOME/tty_ssh/$name
    done

    # Run the container
    KRB5CCACHE=$(klist | head -1 | cut -d : -f 3)
    podman run -it -v $KRB5CCACHE:/tmp/krb5cc_1000                              \
                   -v $HOME/tty_gitconfig:/home/student/.gitconfig:copy,U       \
                   -v $HOME/tty_ssh:/home/student/.ssh/:copy,U                  \
                   localhost/tty_${imageName}:$LATEST_TAG
  '';
in
{
  # Define the shell script to generate the static /etc/issue file
  environment.etc."issue".text = lib.strings.concatStrings [
    (builtins.readFile (pkgs.runCommand "cnix-tty-issue" { buildInputs = with pkgs; [ ncurses ]; } (builtins.readFile ./tty-issue.sh)))
    "\n${config.system.nixos.distroName} ${config.system.nixos.label} (\\m) - \\l\n\n"
  ];

  security.wrappers = {
    download_tty_image = {
      setuid = true;
      owner = "root";
      group = "root";
      source = setuidDownloadWrapper;
    };
  };

  cri = {
    packages.pkgs = {
      podman.enable = true;
    };

    aria2.enable = true;
  };

  netboot.enable = true;

  environment.systemPackages = [
    tty_launch
  ];
}

