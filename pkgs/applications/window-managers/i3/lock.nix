{ lib
, fetchFromGitHub
, autoreconfHook
, systemd
, i3lock
}:

i3lock.overrideAttrs (old: rec {
  pname = "i3lock-cri";
  version = "2.12-cri";

  src = fetchFromGitHub {
    owner = "epita";
    repo = "i3lock";
    rev = version;
    sha256 = "0qk89f44bifj1hxvzqi5gl0rdi5pfnsziwzi3jm7x1v3g2r2iny7";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook ];
  propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ systemd ];

  postPatch = ''
    sed -i -e 's:login:system-auth:' pam/i3lock
  '';

  configureFlags = [ "--disable-sanitizers" ];

  makeFlags = [ ''CPPFLAGS+="-U_FORTIFY_SOURCE"'' ];

  meta = with lib; {
    platforms = platforms.linux;
  };
})
