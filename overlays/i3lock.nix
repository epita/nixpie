_: prev: {
  i3lock = prev.i3lock.overrideAttrs (
    _: rec {
      pname = "i3lock-cri";
      version = "2.12-cri";

      src = prev.fetchFromGitHub {
        owner = "epita";
        repo = "i3lock";
        rev = version;
        sha256 = "0qk89f44bifj1hxvzqi5gl0rdi5pfnsziwzi3jm7x1v3g2r2iny7";
      };

      nativeBuildInputs = prev.i3lock.nativeBuildInputs ++ [ prev.autoreconfHook ];
      propagatedBuildInputs = prev.i3lock.propagatedBuildInputs ++ [ prev.systemd ];

      postPatch = ''
        ${prev.gnused}/bin/sed -i -e 's:login:system-auth:' pam/i3lock
      '';

      configureFlags = [ "--disable-sanitizers" ];

      makeFlags = [ ''CPPFLAGS+="-U_FORTIFY_SOURCE"'' ];
    }
  );
}
