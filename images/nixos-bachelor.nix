{ config, pkgs, system, ... }:

let
  phpMyAdmin = pkgs.stdenv.mkDerivation rec {
    pname = "phpMyAdmin";
    version = "5.2.0";

    src = fetchTarball {
      url = "https://static.cri.epita.fr/phpmyadmin-built-5.2.0.tar.gz";
      sha256 = "0s174m1ky2sqm6m6siss4a9lg6hz7n0kkxfh2yc8vqs0pgydj9si";
    };

    installPhase = ''
      mkdir -p $out
      cp -r * $out

      cp $out/config.sample.inc.php $out/config.inc.php

      echo "\$cfg['Servers'][\$i]['connect_type'] = 'tcp';" >> $out/config.inc.php
      sed -i 's/localhost/127.0.0.1/' $out/config.inc.php
    '';
  };
  phpdev-init = pkgs.writeScriptBin "phpdev-init" ''
        set -e

        MYSQL_DATADIR="$HOME/.mysql_data"
        MYSQL_CONF="$HOME/.my.cnf"
        MYSQL_SOCK="$HOME/.mysqld.sock"
        MYSQL_PID="$HOME/.mysqld.pid"
        PHPDEV_DIR="$HOME/phpdev"

        mkdir -p "$MYSQL_DATADIR" "$PHPDEV_DIR"

        cat > "$MYSQL_CONF" <<EOF
    [mysqld]
    bind-address=127.0.0.1
    datadir=$MYSQL_DATADIR/mysql
    port=3306
    pid-file  = "$MYSQL_PID"
    socket    = "$MYSQL_SOCK"
    EOF

        MYSQLD_OPTIONS="--datadir=$MYSQL_DATADIR"

        if ! test -e "$MYSQL_DATADIR/mysql"; then
              ${pkgs.mariadb}/bin/mysql_install_db --defaults-file=$MYSQL_CONF "$MYSQLD_OPTIONS"
              touch "$MYSQL_DATADIR/mysql_init"
        fi

        mysqld --defaults-file=$MYSQL_CONF "$MYSQLD_OPTIONS" &
        sleep 5
        mysql -S "$MYSQL_SOCK" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; flush privileges;"

        php -S 127.0.0.1:8080 -t "$PHPDEV_DIR" &
        php -S 127.0.0.1:8081 -t "${phpMyAdmin}" &

        echo "READY!"
        echo "  phpMyAdmin: http://localhost:8081"
        echo "  dev server: http://localhost:8080"
        echo "  MySQL running at 127.0.0.1:3306, user: root, password: root"
        echo "You can start developing in the phpdev folder"

        sleep infinity
  '';
in
{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri = {
    sddm = {
      title = "NixOS Bachelor";
      defaultSession = "xfce";
    };
    xfce.enable = true;

    packages = {
      pkgs = {
        dev.enable = true;
      };
      python = {
        dev.enable = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
      ];
    })
    nginx
    mariadb
    php
    phpdev-init
  ];

  cri.packages.pythonPackages.nixosBachelorCustom = p: with p; [
    numpy
    pandas
    scikit-learn
    matplotlib
    networkx
  ];
}
