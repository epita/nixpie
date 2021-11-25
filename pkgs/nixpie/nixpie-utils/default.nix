{ lib
, symlinkJoin
, writeShellScriptBin
, coreutils
, gawk
, gnugrep
, gnused
, inetutils
, iproute2
}:

let
  wait_for_hostname = ''
    n=0
    until [ "''${n}" -ge 15 ] || ${gnugrep}/bin/grep domain /etc/resolv.conf 2>&1 >/dev/null; do
      n="$(( ''${n} + 1 ))"
      sleep 2
    done
  '';
  get_ip = writeShellScriptBin "get_ip.sh" ''
    while true; do
      ip="$(${iproute2}/bin/ip address \
        | ${gnugrep}/bin/grep 'inet ' \
        | ${gnugrep}/bin/grep -v '127.0.0.' \
        | ${coreutils}/bin/head -n1 \
        | ${gawk}/bin/awk '{ print $2 }' \
        | ${coreutils}/bin/cut -d/ -f1\
      )"
      if [ -n "$ip" ] ; then
        break
      fi
      sleep 2
    done
    echo "''${ip}"
  '';
  get_room_name = writeShellScriptBin "get_room_name.sh" ''
    ${wait_for_hostname}
    ${gnugrep}/bin/grep domain /etc/resolv.conf \
      | ${gawk}/bin/awk '{ print $2 }' \
      | ${gnused}/bin/sed 's/.sm.cri.epita.fr//' | cut -d. -f1
  '';
  get_site_name = writeShellScriptBin "get_site_name.sh" ''
    ${wait_for_hostname}
    ${gnugrep}/bin/grep domain /etc/resolv.conf \
      | ${gawk}/bin/awk '{ print $2 }' \
      | ${gnused}/bin/sed 's/.sm.cri.epita.fr//' | cut -d. -f2
  '';
in
symlinkJoin {
  name = "nixpie-utils";

  paths = [
    get_ip
    get_room_name
    get_site_name
  ];

  meta = with lib; {
    platforms = platforms.linux;
  };
}
