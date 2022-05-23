{ config, pkgs, lib, ... }:

let
  execScript = pkgs.writeShellScript "exec.sh" ''
    set -xu

    EXEC_URL="$(cat /proc/cmdline | ${pkgs.gnused}/bin/sed 's/.*exec_url=\([^ ]*\).*/\1/')"

    if [ -x ${pkgs.exec-tools}/bin/''${EXEC_URL} ]; then
      ${pkgs.exec-tools}/bin/''${EXEC_URL}
    else
      # Wait for network to be ready
      ${pkgs.nixpie-utils}/bin/get_ip.sh
      ${pkgs.wget}/bin/wget "''${EXEC_URL}" -O /tmp/script.sh
      chmod +x /tmp/script.sh
      /tmp/script.sh
    fi

    echo "Shutdown in 10s"
    read -t 10 -p "Hit ENTER to drop into a shell" || ${pkgs.systemd}/bin/poweroff
    exec ${pkgs.bash}/bin/bash
  '';
in
{
  netboot = {
    enable = true;
    bootcache.enable = lib.mkForce false;
    nix-store-rw.enable = lib.mkForce false;
    home.enable = lib.mkForce false;
    swap.enable = lib.mkForce false;
  };

  cri = {
    afs.enable = false;
    krb5.enable = false;
    ldap.enable = false;
    users.createEpitaUser = false;
  };

  boot.supportedFilesystems = [ "nfs" ]; # To create dumps

  boot.kernelParams = [ "exec_url=htop.sh" ];

  users.users.root.password = lib.mkForce "";

  services.getty = {
    loginProgram = "${pkgs.bash}/bin/bash";
    loginOptions = "${execScript}";
    autologinUser = "root";
  };
}
