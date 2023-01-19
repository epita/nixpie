{ stdenv, lib, fetchFromGitHub, i3lock, systemd }:

i3lock.overrideAttrs (old: rec {
  pname = "i3lock-cri";
  version = "2.14.1-cri";

  src = fetchFromGitHub {
    owner = "epita";
    repo = "i3lock";
    rev = version;
    sha256 = "sha256-hybNDRmC0St4sMz0Ff98G+a4kz0Nex4itrsRKu7tSHY=";
  };

  propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ systemd ];

  postPatch = ''
    sed -i -e 's:login:system-auth:' pam/i3lock
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
})
