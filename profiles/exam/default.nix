{ pkgs, lib, ... }:

{
  cri.afs.enable = false;

  netboot = {
    nix-store-rw.enable = false;
  };

  networking.firewall.enable = false;

  services.xserver.windowManager.i3 = {
    extraSessionCommands = lib.mkAfter ''
      ${pkgs.rxvt-unicode}/bin/urxvt -e ${pkgs.exam-start}/bin/exam-start &
    '';
  };

  environment.systemPackages = with pkgs; [
    exam-start
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

          # accept traffic originated from us
          ct state {established, related} accept

          # Allow DNS (ns.pie.cri.epita.fr)
          ip daddr 10.224.21.53 udp dport domain accept

          # Reverse CRI
          ip daddr 10.224.4.2 tcp dport {http,https} accept

          # Git Exam CRI
          ip daddr 10.224.4.2 tcp dport ssh accept

          # Ingress k8s prod-1
          ip daddr 10.224.21.80 tcp dport {http,https} accept

          # kerberos.pie.cri.epita.fr
          ip daddr 91.243.117.186 tcp dport {kerberos,kerberos-adm} accept
          # ldap.pie.cri.epita.fr
          ip daddr 91.243.117.185 tcp dport {ldap,ldaps} accept

          # s3.cri.epita.fr
          ip daddr 91.243.117.208 tcp dport {http,https} accept

          # NTP
          ip daddr 10.224.4.2 udp dport ntp accept

          # Salt
          ip daddr {10.224.4.0/24,10.224.21.0/24} tcp dport {4505,4506} accept

          # Jetbrains license server
          ip daddr 52.30.108.61 tcp dport https accept

          # Intellij + Gradle
          # plugins.jetbrains.com
          # repo1.maven.org
          # services.gradle.org
          ip daddr {52.208.50.140,151.101.120.209,104.16.171.166,104.16.172.166,104.16.173.166,104.16.174.166,104.16.175.166} tcp dport https accept

          # api.nuget.org
          ip daddr 152.199.23.209 tcp dport {http,https} accept

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
