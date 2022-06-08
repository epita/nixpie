{ config, pkgs, ... }:
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
    '';
  };
  phpMyAdminAlias = pkgs.writeScriptBin "phpmyadmin" ''
    echo "Opening phpMyAdmin in browser..."
    ${pkgs.xdg-utils}/bin/xdg-open http://localhost >/dev/null 2>/dev/null </dev/null & disown
  '';
in
{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SQL";

  environment.systemPackages = with pkgs; [ mariadb phpMyAdminAlias ];

  services.nginx = {
    enable = true;
    defaultListenAddresses = [ "127.0.0.1" ];
    virtualHosts."_" = {
      root = phpMyAdmin;
      locations."/".index = "index.php index.html index.htm";
      locations."~ \.php$".extraConfig = ''
        fastcgi_pass  unix:${config.services.phpfpm.pools.nixpie.socket};
        fastcgi_index index.php;
      '';
    };
  };

  services.phpfpm.pools.nixpie = {
    user = "nginx";
    group = "nginx";
    settings = {
      "pm" = "static";
      "pm.max_children" = 10;
      "listen.owner" = config.services.nginx.user;
    };
    phpOptions = ''
      upload_max_filesize = 10M
      post_max_size = 10M
    '';
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
      };
    };
    initialDatabases = [
      {
        name = "epita";
      }
    ];
    initialScript = pkgs.writeText "epita-mysql-init" ''
      CREATE USER IF NOT EXISTS 'epita'@'localhost' IDENTIFIED BY 'epita';
      GRANT ALL PRIVILEGES ON epita.* TO 'epita'@'localhost';
      FLUSH PRIVILEGES;
    '';
  };
}
