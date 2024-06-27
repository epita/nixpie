{ config, pkgs, lib, ... }:

with lib;

let
  proxypac = pkgs.writeTextDir "wpad.dat" ''
    function FindProxyForURL (url, host) {
      return 'PROXY localhost:8118; DIRECT';
    }
  '';
  privoxyRuntimePath = "/var/run/privoxy";
  privoxyActionsPath = "/var/run/privoxy/epita.actions";
  privoxyCertDirPath = "/etc/privoxy";
  privoxyCACertPath = "/etc/privoxy/cacert.crt";
  privoxyCAKeyPath = "/etc/privoxy/cakey.key";
in
{
  options = {
    cri.privoxy = {
      enable = mkEnableOption "Whether to enable privoxy";
      actionsEndpoint = mkOption {
        type = types.str;
        default = "https://s3.cri.epita.fr/cri-fleet-manager/privoxy.actions";
        description = "privoxy dynamic action config endpoint";
      };
    };
  };

  config = mkIf config.cri.privoxy.enable {
    system.activationScripts.privoxy-ca-gen = {
      deps = [ "users" "groups" "etc" ];
      text = ''
        if [[ ! -f "${privoxyCACertPath}" ]]; then
          mkdir -p ${privoxyCertDirPath}

          ${pkgs.openssl}/bin/openssl req -new -newkey rsa:2048 -sha256 \
            -days 3650 -nodes -x509 -extensions v3_ca \
            -keyout ${privoxyCAKeyPath} -out ${privoxyCACertPath} \
            -subj '/CN=Exam proxy CA/C=FR/ST=Val-de-Marne/L=Le Kremlin-Bicetre/O=EPITA Forge'

          chown -R root:privoxy ${privoxyCertDirPath}
          chmod 640 ${privoxyCertDirPath}/*
        fi


        # Remove symlink created by nix
        rm /etc/ssl/certs/ca-certificates.crt
        rm /etc/ssl/certs/ca-bundle.crt
        rm /etc/pki/tls/certs/ca-bundle.crt

        # Add our CA to system's CA bundle
        cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ${privoxyCACertPath} > /etc/ssl/certs/ca-certificates.crt
        cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ${privoxyCACertPath} > /etc/ssl/certs/ca-bundle.crt
        cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ${privoxyCACertPath} > /etc/pki/tls/certs/ca-bundle.crt
      '';
    };

    services.privoxy = {
      enable = true;
      inspectHttps = true;
      settings = {
        actionsfile = [ privoxyActionsPath ];
        debug = [ 1 1024 ]; # log requests
        enable-remote-toggle = false;
        enable-edit-actions = false;
        enable-remote-http-toggle = false;
        enforce-blocks = true;
        ca-cert-file = privoxyCACertPath;
        ca-key-file = privoxyCAKeyPath;
      };
    };

    systemd.tmpfiles.rules = [ "d ${privoxyRuntimePath} 0770 privoxy privoxy" ];

    systemd.services.privoxy = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      preStart = ''
        ${pkgs.curl}/bin/curl --fail -o ${privoxyActionsPath} "${config.cri.privoxy.actionsEndpoint}"
      '';
      serviceConfig = {
        Restart = "on-failure";
      };
    };

    networking.proxy = {
      httpProxy = "http://127.0.0.1:8118";
      httpsProxy = "http://127.0.0.1:8118";
    };

    networking.hosts = {
      "127.0.0.1" = [ "wpad" ];
    };

    services.lighttpd = {
      enable = true;
      document-root = proxypac;
    };
  };
}
