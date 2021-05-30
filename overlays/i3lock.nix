final: prev: {
  i3lock = prev.i3lock.overrideAttrs (old: rec {
    pname = "i3lock-cri";
    version = "2.12-cri";

    src = final.fetchFromGitHub {
      owner = "epita";
      repo = "i3lock";
      rev = version;
      sha256 = "0qk89f44bifj1hxvzqi5gl0rdi5pfnsziwzi3jm7x1v3g2r2iny7";
    };

    nativeBuildInputs = old.nativeBuildInputs ++ [ final.autoreconfHook ];
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ final.systemd ];

    postPatch = ''
      ${final.gnused}/bin/sed -i -e 's:login:system-auth:' pam/i3lock
    '';

    configureFlags = [ "--disable-sanitizers" ];

    makeFlags = [ ''CPPFLAGS+="-U_FORTIFY_SOURCE"'' ];

    meta = with final.lib; {
      platforms = platforms.linux;
    };
  });
}
