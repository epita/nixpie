{ pkgs, lib, ... }:

let
  submission = pkgs.writeShellScriptBin "submission" ''
    #!/bin/sh

    if [ ! -f ~/.allow_submission ]; then
      echo -e "[\033[31mERROR\033[0m] Submission script not allowed"
      exit 1
    fi

    cd "$HOME/submission"

    echo "* Trying to submit"

    git checkout master
    git add --all
    git commit -m "Submission" --allow-empty
    git push origin master
  '';

  proxypac = pkgs.writeTextDir "wpad.dat" ''
    function FindProxyForURL (url, host) {
      return 'PROXY localhost:3128; DIRECT';
    }
  '';
in
{
  cri.afs.enable = false;

  netboot = {
    nix-store-rw.enable = false;
  };

  networking.firewall.enable = false;

  services.xserver.windowManager.i3 = {
    extraSessionCommands = lib.mkAfter ''
      ${pkgs.i3}/bin/i3-sensible-terminal -e ${pkgs.exam-start}/bin/exam-start &
    '';
  };

  environment.systemPackages = with pkgs; [
    exam-start
    submission
  ];

  # Warning: do not use domain names in these rules, at the risk of the
  # firewall starting before a nameserver could be fetched from the DHCP
  # server, in which case you might not have a firewall at all.
  networking.nftables = {
    enable = true;
    preCheckRuleset = ''
      sed 's/skuid squid/skuid nobody/g' -i ruleset.conf
    '';
    ruleset = ''
      table inet filter {
        # Block all incomming connections traffic except SSH and "ping".
        chain input {
          type filter hook input priority 0;

          # accept any localhost traffic
          iifname lo accept

          # accept traffic originated from us
          ct state {established, related} accept

          # accept SSH connections (required for a server)
          tcp dport 22 accept

          # accept node-exporter
          tcp dport 9100 accept

          # Allow ICMP
          ip protocol icmp accept

          drop
        }

        # Allow all outgoing connections.
        chain output {
          type filter hook output priority 0;

          # accept any localhost traffic
          iifname lo accept
          ip daddr 127.0.0.0/8 accept

          # accept traffic originated from us
          ct state {established, related} accept

          # Allow DNS (kresd)
          ip daddr 10.224.21.53 udp dport domain accept
          ip daddr 10.201.5.53 udp dport domain accept

          # kerberos.pie.cri.epita.fr
          ip daddr 91.243.117.186 tcp dport {kerberos,kerberos-adm} accept
          # ldap.pie.cri.epita.fr
          ip daddr 91.243.117.185 tcp dport {ldap,ldaps} accept

          # Git Exam CRI
          ip daddr 10.224.21.122 tcp dport ssh accept
          ip daddr 10.201.5.122 tcp dport ssh accept

          # Git Exam Forge
          ip daddr 10.224.21.123 tcp dport ssh accept

          # NTP
          ip daddr 10.224.4.2 udp dport ntp accept
          ip daddr 10.201.5.2 udp dport ntp accept

          # Salt
          ip daddr {10.224.4.0/24,10.224.21.0/24} tcp dport {4505,4506} accept
          ip daddr {10.201.5.0/24,10.201.5.0/24} tcp dport {4505,4506} accept

          meta skuid root accept
          tcp dport {http, https} meta skuid squid accept

          drop
        }

        chain forward {
          type filter hook forward priority 0;
          drop
        }
      }
    '';
  };

  systemd.services.nftables = {
    serviceConfig = {
      Restart = "on-failure";
    };
  };

  services.squid = {
    enable = true;
    proxyAddress = "127.0.0.1";
    configText = ''
      # Reverse CRI
      acl whitelistip dst 10.224.4.2
      acl whitelistip dst 10.201.5.2

      # Ingress k8s prod-1
      acl whitelistip dst 10.224.21.80
      acl whitelistip dst 10.201.5.80

      # s3.cri.epita.fr
      acl whitelistip dst 91.243.117.208

      # Intellij + Gradle
      acl whitelistdomain dstdomain repo1.maven.org
      acl whitelistdomain dstdomain services.gradle.org
      acl whitelistdomain dstdomain api.nuget.org

      acl whitelistdomain dstdomain www.jetbrains.com
      acl whitelistdomain dstdomain plugins.jetbrains.com
      acl whitelistdomain dstdomain download.jetbrains.com
      acl whitelistdomain dstdomain download-cdn.jetbrains.com
      acl whitelistdomain dstdomain frameworks.jetbrains.com
      acl whitelistdomain dstdomain vortex.data.microsoft.com
      acl whitelistdomain dstdomain marketplace.visualstudio.com

      # Scala maven repositories
      acl whitelistdomain dstdomain repo.scala-sbt.org
      acl whitelistdomain dstdomain repo.typesafe.com

      # Electif BLSC SmartPy
      acl whitelistdomain dstdomain smartpy.io
      acl whitelistdomain dstdomain fonts.googleapis.com
      acl whitelistdomain dstdomain cdn.jsdelivr.net
      acl whitelistdomain dstdomain fonts.gstatic.com

      acl whitelistdomain dstdomain ocsp.pki.goog

      acl Safe_ports port 80          # http
      acl Safe_ports port 443         # https

      http_access deny !Safe_ports
      http_access allow whitelistip
      http_access allow whitelistdomain

      # Application logs to syslog, access and store logs have specific files
      cache_log       syslog
      access_log      stdio:/var/log/squid/access.log
      cache_store_log stdio:/var/log/squid/store.log

      # Required by systemd service
      pid_filename    /run/squid.pid

      # Run as user and group squid
      cache_effective_user squid squid

      # And finally deny all other access to this proxy
      http_access deny all

      # Squid normally listens to port 3128
      http_port 3128

      # Leave coredumps in the first cache dir
      coredump_dir /var/cache/squid

      cache_mgr tickets@forge.epita.fr
    '';
  };

  systemd.services.squid = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  systemd.services.dns-online = {
    description = "wait for DNS to be online";
    after = [ "nss-lookup.target" ];
    before = [ "network-online.target" ];
    wantedBy = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 60;
    };

    script = ''
      while ! ${pkgs.host}/bin/host -t A cri.epita.fr; do
        sleep 1;
      done
    '';
  };

  networking.proxy = {
    httpProxy = "http://127.0.0.1:3128";
    httpsProxy = "http://127.0.0.1:3128";
  };

  networking.hosts = {
    "127.0.0.1" = [ "wpad" ];
  };

  services.lighttpd = {
    enable = true;
    document-root = proxypac;
  };
}
