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
  cri.packages.pkgs.desktop.firefox = {
    extraPolicies = {
      Proxy = {
        Mode = "manual";
        Locked = true;
        HTTPProxy = "127.0.0.1:8118";
        SSLProxy = "127.0.0.1:8118";
        SOCKSProxy = ""; # see https://bugzilla.mozilla.org/show_bug.cgi?id=1823693
        UseHTTPProxyForAllProtocols = true;
      };
    };
    toolbarBookmarks = [
      {
        Title = "Moodle Exam";
        URL = "https://moodle-exam.epita.fr";
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
  };

  netboot = {
    nix-store-rw.enable = false;
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22 # SSH
      9100 # node-exporter
    ];

    allowPing = true;

    # Warning: do not use domain names in these rules, at the risk of the
    # firewall starting before a nameserver could be fetched from the DHCP
    # server, in which case you might not have a firewall at all.
    extraCommands = ''
      ${pkgs.nftables}/bin/nft delete table inet output-filter 2>/dev/null || true

      ${pkgs.nftables}/bin/nft -f - <<'EOF'
      table inet output-filter {
        chain output {
          type filter hook output priority 0; policy drop;

          # Accept any localhost traffic
          iifname lo accept
          oifname lo accept
          ip daddr 127.0.0.0/8 accept

          # Accept traffic originated from us
          ct state { established, related } accept

          # Allow DNS (kresd)
          ip daddr 10.201.5.53 udp dport 53 accept

          # kerberos.pie.cri.epita.fr
          ip daddr 91.243.117.186 tcp dport { 88, 749 } accept
          # ldap.pie.cri.epita.fr
          ip daddr 91.243.117.185 tcp dport { 389, 636 } accept
          # Internal IP address for LDAP and Kerberos
          ip daddr 10.201.5.54 tcp dport { 389, 636, 88, 749 } accept

          # Git Exam CRI
          ip daddr 10.201.5.122 tcp dport 22 accept

          # Git Exam Forge
          ip daddr 10.201.5.123 tcp dport 22 accept

          # NTP
          ip daddr 10.201.5.2 udp dport 123 accept

          # Salt
          ip daddr 10.201.5.0/24 tcp dport { 4505, 4506 } accept

          # Allow root to do anything
          meta skuid root accept

          # Allow privoxy to access HTTP/HTTPS
          tcp dport { 80, 443 } meta skuid privoxy accept
        }

        chain forward {
          type filter hook forward priority 0; policy drop;
        }
      }
      EOF
    '';

    extraStopCommands = ''
      ${pkgs.nftables}/bin/nft delete table inet output-filter 2>/dev/null || true
    '';
  };

  services.xserver.windowManager.i3 = {
    extraSessionCommands = lib.mkAfter ''
      ${pkgs.exam-start}/bin/exam-start &
    '';
  };

  environment.systemPackages = with pkgs; [
    exam-start
    submission
    nftables
  ];

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
