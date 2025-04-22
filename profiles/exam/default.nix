{ pkgs, lib, ... }:

let
  submission = pkgs.writeShellScriptBin "submission" ''
    #!/bin/sh

    echo "* Trying to submit"

    git checkout master
    git add --all
    git commit -m "Submission" --allow-empty
    git tag -a "submission-$(git rev-parse --short HEAD)" -m "Submission"
    git push origin master --follow-tags
  '';
in
{
  cri.afs.enable = false;
  cri.packages.pkgs.desktop.firefox.toolbarBookmarks = [
    {
      Title = "Moodle Exam";
      URL = "https://moodle-exam.cri.epita.fr";
    }
    {
      Title = "Intranet Exam";
      URL = "https://exam.forge.epita.fr";
    }
    {
      Title = "Intranet Exam - Remaining time";
      URL = "https://exam.forge.epita.fr/_exam/session";
    }
  ];

  netboot = {
    nix-store-rw.enable = false;
  };

  networking.firewall.enable = false;

  services.xserver.windowManager.i3 = {
    extraSessionCommands = lib.mkAfter ''
      ${pkgs.exam-start}/bin/exam-start &
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
      sed 's/skuid privoxy/skuid nobody/g' -i ruleset.conf
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
          ip daddr 10.201.5.53 udp dport domain accept

          # kerberos.pie.cri.epita.fr
          ip daddr 91.243.117.186 tcp dport {kerberos,kerberos-adm} accept
          # ldap.pie.cri.epita.fr
          ip daddr 91.243.117.185 tcp dport {ldap,ldaps} accept
          # internal IP address for LDAP and Kerberos
          ip daddr 10.201.5.54 tcp dport {ldap,ldaps,kerberos,kerberos-adm} accept

          # Git Exam CRI
          ip daddr 10.201.5.122 tcp dport ssh accept

          # Git Exam Forge
          ip daddr 10.201.5.123 tcp dport ssh accept

          # NTP
          ip daddr 10.201.5.2 udp dport ntp accept

          # Salt
          ip daddr 10.201.5.0/24 tcp dport {4505,4506} accept

          meta skuid root accept
          tcp dport {http, https} meta skuid privoxy accept

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

  cri.privoxy.enable = true;

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
}
