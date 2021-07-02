{ config, pkgs, lib, ... }:

let
  execScript = pkgs.writeShellScript "exec.sh" ''
    set -xu

    EXEC_URL="$(cat /proc/cmdline | ${pkgs.gnused}/bin/sed 's/.*exec_url=\([^ ]*\).*/\1/')"

    if [ -x ${pkgs.exec-tools}/bin/''${EXEC_URL} ]; then
      ${pkgs.exec-tools}/bin/''${EXEC_URL}
    else
      ${pkgs.wget}/bin/wget "''${EXEC_URL}" -O /tmp/script.sh
      chmod -x /tmp/script.sh
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
    bootcache.enable = false;
  };

  cri = {
    afs.enable = false;
    krb5.enable = false;
    ldap.enable = false;
    users.createEpitaUser = false;
  };

  users.users.root.password = lib.mkForce "";

  systemd.services."autovt@tty1" = {
    after = [ "systemd-logind.service" "multi-user.target" ];
    serviceConfig.ExecStart = [
      "" # override upstream default with an empty ExecStart
      ''
        @${pkgs.util-linux}/sbin/agetty agetty \
        --autologin root \
        --login-program ${pkgs.bash}/bin/bash \
        --login-options ${execScript} \
        --noclear --keep-baud \
        %I 115200,38400,9600 $TERM
      ''
    ];
    restartIfChanged = false;
  };
}
