{ config, pkgs, lib, ... }:

let
  localServerIp = "192.168.37.1";
  startServer = pkgs.writeScriptBin "laptop-start-server" ''
    if ${pkgs.lldpd}/bin/lldpcli show neighbors ports eth0 | ${pkgs.gnugrep}/bin/grep -q ionis-it ; then
      echo "You are still plugged in the machine room network."
      exit 1
    fi

    systemctl stop machine-room-client.target
    systemctl stop dhcpcd
    ip addr add ${localServerIp}/24 dev eth0
    systemctl start standalone-server.target
    systemctl start atftpd nginx samba.target dhcpd4
    echo DONE
  '';
  stopServer = pkgs.writeScriptBin "laptop-stop-server" ''
    systemctl stop standalone-server.target
    systemctl stop atftpd nginx samba.target dhcpd4
    ip addr del ${localServerIp}/24 dev eth0
    systemctl start machine-room-client.target
    systemctl start dhcpcd
    echo DONE
  '';
in
{
  netboot = {
    enable = true;
    home.enable = lib.mkForce false;
    swap.enable = lib.mkForce false;
  };

  cri = {
    afs.enable = false;
    krb5.enable = false;
    ldap.enable = false;
  };

  networking.firewall.enable = false;

  # easier password for students in case of emergency
  users.users.root.hashedPassword = lib.mkForce "$6$9qWcIgs2Imjbs7MH$iUCDDI4YCtmRUbrDaLN59uJ2rgJNqCF5W2VgWw3yhUUrsK/QIaKSYin.VCF/O7ZZI9y6kwaSMUfQ2ZXfgPqMY0";
  users.users.root.initialHashedPassword = lib.mkForce "$6$9qWcIgs2Imjbs7MH$iUCDDI4YCtmRUbrDaLN59uJ2rgJNqCF5W2VgWw3yhUUrsK/QIaKSYin.VCF/O7ZZI9y6kwaSMUfQ2ZXfgPqMY0";

  systemd.services.laptop-installer-requirements = {
    description = "Laptop Installer Requirements";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" "srv-torrent.mount" ];
    wants = [ "network-online.target" "srv-torrent.mount" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ findutils gnugrep curl gnutar gzip xz aria2 ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      # clean up squashfs to make room
      find /srv/torrent -name '*.squashfs' ! -name 'nixos-laptop-install.squashfs' -delete || true

      # prepare folder and copy ipxe efi
      mkdir -p /srv/torrent/laptop/doc
      chown -R nginx:nginx /srv/torrent/laptop

      # DOCUMENTATION SECTION
      curl -o /tmp/documentation.tar.xz https://s3.cri.epita.fr/cri-nico-uploads/laptop-install-doc.tar.xz
      mkdir -p /srv/torrent/laptop/{doc,laptop}
      tar xvf /tmp/documentation.tar.xz -C /srv/torrent/laptop/doc
      chown -R nginx:nginx /srv/torrent/laptop/doc

      # WINDOWS FILES AND IPXE MENU SECTION
      curl -o /srv/torrent/laptop/menu.ipxe https://s3.cri.epita.fr/cri-nico-uploads/laptop-install.ipxe
      curl -o /srv/torrent/laptop/ipxe.efi https://s3.cri.epita.fr/cri-nico-uploads/ipxe.efi
      curl -o /srv/torrent/laptop/laptop/winpeshl.ini https://s3.cri.epita.fr/cri-nico-uploads/winpeshl.ini
      curl -o /srv/torrent/laptop/laptop/install.bat https://s3.cri.epita.fr/cri-nico-uploads/install.bat
      chown nginx:nginx /srv/torrent/laptop/menu.ipxe
      chown nginx:nginx /srv/torrent/laptop/laptop/winpeshl.ini
      chown nginx:nginx /srv/torrent/laptop/laptop/install.bat

      # TORRENT SECTION
      curl -o /srv/torrent/laptop-bundle.torrent https://s3.cri.epita.fr/cri-nico-uploads/laptop-bundle.torrent

      aria2_base="-V --file-allocation=prealloc --enable-mmap=true --bt-enable-lpd=true"
      aria2_summary="--summary-interval=60"
      aria2_nodht="--enable-dht=false --enable-dht6=false"
      aria2_noseed="--seed-time=0 --seed-ratio=0"
      aria2_opts="$aria2_base $aria2_summary $aria2_nodht $aria2_noseed"

      aria2c $aria2_opts --check-integrity --dir=/srv/torrent/laptop /srv/torrent/laptop-bundle.torrent

      chmod -R 777 /srv/torrent/laptop/laptop/windows
    '';
  };

  systemd.services.aria2 = {
    preStart = ''
      file=${config.cri.aria2.seedlist}

      cat >$file <<EOF
      /srv/torrent/nixos-laptop-install.torrent
       index-out=1=nixos-laptop-install.squashfs
       dir=/srv/torrent
       check-integrity=true
      /srv/torrent/laptop-bundle.torrent
       dir=/srv/torrent/laptop
       check-integrity=true
      EOF
    '';
    partOf = [ "machine-room-client.target" ];
    after = [ "laptop-installer-requirements.service" ];
  };

  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      option space ipxe;
      option ipxe.no-pxedhcp code 176 = unsigned integer 8;
      option ipxe.http code 19 = unsigned integer 8;


      ignore-client-uids true;
      next-server ${localServerIp};
      subnet 192.168.37.0 netmask 255.255.255.0 {
        range 192.168.37.100 192.168.37.200;
      }

      option ipxe.no-pxedhcp 1;

      if exists user-class and option user-class = "iPXE" {
        filename "http://${localServerIp}/menu.ipxe";
      } else {
          filename "ipxe.efi";
      }
    '';
  };
  systemd.services.dhcpd4.partOf = [ "standalone-server.target" ];

  services.atftpd = {
    enable = true;
    root = "/srv/torrent/laptop";
  };
  systemd.services.atftpd.partOf = [ "standalone-server.target" ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      localhost = {
        default = true;
        root = "/srv/torrent/laptop";
      };
    };
  };
  systemd.services.nginx.partOf = [ "standalone-server.target" ];

  services.samba = {
    enable = true;
    shares = {
      torrent = {
        path = "/srv/torrent/laptop";
        "read only" = true;
        browseable = "yes";
        "guest ok" = "yes";
      };
    };
  };
  systemd.targets.samba.partOf = [ "standalone-server.target" ];

  # Target activated when not plugged in machine room and acting as boot server
  systemd.targets.standalone-server = {
    description = "Laptop install server";
    after = [ "machine-room-client.target" "laptop-installer-requirements.service" ];
    conflicts = [ "machine-room-client.target" ];
  };

  # Target activated when  plugged in machine room and acting as client
  systemd.targets.machine-room-client = {
    conflicts = [ "standalone-server.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "Machine room client";
  };

  systemd.services.room-network-check = {
    wants = [ "lldpd.service" ];
    requires = [ "lldpd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ lldpd gnugrep systemd iproute2 ];
    serviceConfig = {
      Restart = "always";
    };
    script = ''
      while true; do
        if lldpcli show neighbors ports eth0 | grep -q ionis-it ; then
          if systemctl is-active --quiet standalone-server.target ; then
            ${stopServer}/bin/laptop-stop-server
          fi
        fi
        sleep 3
      done
    '';
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "radeon" "cirrus" "vesa" "vmware" "modesetting" "intel" ];
    windowManager.openbox.enable = true;
    displayManager.autoLogin.user = "epita";
    displayManager.defaultSession = "none+openboxlaptop";
    displayManager.session = [{
      name = "openboxlaptop";
      manage = "window";
      start = ''
        firefox http://localhost/doc/ &
        ${pkgs.openbox}/bin/openbox-session &
        waitPID=$!
      '';
    }];
  };
  environment.systemPackages = with pkgs; [
    firefox
    startServer
    stopServer
  ];
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
    ];
    fontconfig = {
      enable = true;
      hinting.enable = true;
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "epita" ];
      commands = [
        { command = "${startServer}/bin/laptop-start-server"; options = [ "NOPASSWD" ]; }
        { command = "${stopServer}/bin/laptop-stop-server"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
