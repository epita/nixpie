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

          # Reverse CRI
          ip daddr 10.224.4.2 tcp dport {http,https} accept
          ip daddr 10.201.5.2 tcp dport {http,https} accept

          # Git Exam CRI
          ip daddr 10.224.21.122 tcp dport ssh accept
          ip daddr 10.201.5.122 tcp dport ssh accept

          # Ingress k8s prod-1
          ip daddr 10.224.21.80 tcp dport {http,https} accept
          ip daddr 10.201.5.80 tcp dport {http,https} accept

          # kerberos.pie.cri.epita.fr
          ip daddr 91.243.117.186 tcp dport {kerberos,kerberos-adm} accept
          # ldap.pie.cri.epita.fr
          ip daddr 91.243.117.185 tcp dport {ldap,ldaps} accept

          # s3.cri.epita.fr
          ip daddr 10.224.21.208 tcp dport {http,https} accept
          ip daddr 91.243.117.208 tcp dport {http,https} accept

          # NTP
          ip daddr 10.224.4.2 udp dport ntp accept
          ip daddr 10.201.5.2 udp dport ntp accept

          # Salt
          ip daddr {10.224.4.0/24,10.224.21.0/24} tcp dport {4505,4506} accept
          ip daddr {10.201.5.0/24,10.201.5.0/24} tcp dport {4505,4506} accept

          # Intellij + Gradle

          # repo1.maven.org
          ip daddr {199.232.192.209,199.232.196.209} tcp dport https accept

          # services.gradle.org
          ip daddr {104.18.190.9,104.18.191.9} tcp dport https accept

          # api.nuget.org
          ip daddr 152.199.23.209 tcp dport {http,https} accept

          # Jetbrains license server
          ip daddr 52.30.108.61 tcp dport https accept

          # www.jetbrains.com
          ip daddr {18.200.1.3,18.200.1.21} tcp dport https accept

          # download.jetbrains.com
          ip daddr {52.30.174.243,52.50.241.213} tcp dport https accept

          # plugins.jetbrains.com, download-cdn.jetbrains.com, frameworks.jetbrains.com (CloudFront)
          ip daddr {99.84.0.0/16,99.86.0.0/16,13.249.0.0/16} tcp dport https accept

          # vortex.data.microsoft.com
          ip daddr 40.77.226.250 tcp dport https accept

          # marketplace.visualstudio.com
          ip daddr 13.107.42.18 tcp dport https accept

          # ocsp.pki.goog
          ip daddr 142.250.75.227 tcp dport {http,https} accept

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
}
