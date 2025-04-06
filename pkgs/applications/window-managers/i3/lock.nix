{ stdenv, lib, i3lock, systemd }:

i3lock.overrideAttrs (old: rec {
  propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ systemd ];

  patches = [
    ./i3lock-epita.patch
    ./0002-fix-sd-bus-kill-session-instead-of-terminating-it.patch
  ];

  postPatch = ''
    sed -i -e 's:login:system-auth:' pam/i3lock
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
})
