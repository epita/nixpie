{ lib
, fetchurl
, stdenv
, makeWrapper
, buildFHSUserEnv
, perl
, bc
, bzip2
, cifs-utils
, coreutils
, dialog
, dosfstools
, ecryptfs
, file
, gptfdisk
, gzip
, lbzip2
, lrzip
, lvm2
, lzop
, ncurses
, ntfs3g
, partclone
, parted
, partimage
, pbzip2
, pigz
, pixz
, procps
, screen
, sshfs
, xz
}:

let
  pname = "clonezilla";
  version = "5.6.13";

  meta = with lib; {
    description = "ncurses partition and disk imaging/cloning program";
    homepage = "https://clonezilla.org";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };

  clonezilla = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "http://free.nchc.org.tw/drbl-core/src/stable/${pname}-${version}.tar.xz";
      sha256 = "sha256-5BDJSicJbebQQQGFIk2W1ewuas8Znt6P+TRLlNkUXmM=";
    };

    nativeBuildInputs = [ makeWrapper ];

    propagatedBuildInputs = [ perl ];

    postPatch = ''
      sed -i 's@$(DESTDIR)/usr@$(DESTDIR)@g' Makefile
      sed -i 's@''${DESTDIR}/usr@''${DESTDIR}@g' Makefile
    '';

    installFlags = [
      "DESTDIR=$(out)"
      "SHAREDIR=share/drbl"
    ];

    inherit meta;
  };
  drbl = stdenv.mkDerivation rec {
    pname = "drbl";
    version = "5.3.2";

    src = fetchurl {
      url = "http://free.nchc.org.tw/drbl-core/src/stable/${pname}-${version}.tar.xz";
      sha256 = "sha256-lEH8/qQLJOj1oSl9ox9NGRLMbKT0Fjy2TXJkKv8oUoA=";
    };

    propagatedBuildInputs = [ perl ];

    postPatch = ''
      sed -i 's@$(DESTDIR)/usr@$(DESTDIR)@g' Makefile
      sed -i 's@''${DESTDIR}/usr@''${DESTDIR}@g' Makefile
      cat Makefile
    '';

    installFlags = [
      "DESTDIR=$(out)"
      "SHAREDIR=share/drbl"
    ];

    meta = with lib; {
      description = "Diskless Remote Boot in Linux: manage the deployment of the GNU/Linux operating system across many clients";
      homepage = "https://drbl.org";
      license = licenses.gpl2;
      platforms = platforms.linux;
    };
  };
in
buildFHSUserEnv {
  name = pname;
  targetPkgs = pkgs: [
    clonezilla
    drbl
    bc
    bzip2
    cifs-utils
    coreutils
    dialog
    dosfstools
    ecryptfs
    file
    gptfdisk
    gzip
    lbzip2
    lrzip
    (lvm2.overrideAttrs (old: {
      # nixpkgs issue 369732
      # https://github.com/NixOS/nixpkgs/issues/369732
      configureFlags = old.configureFlags ++ [ "--with-default-profile-subdir=profile.d" ];
    }))
    lzop
    ntfs3g
    (partclone.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ ncurses ];
      configureFlags = old.configureFlags ++ [ "--enable-ncursesw" ];
      hardeningDisable = [ "format" ]; #FIXME: I don't know why this is necessary
    }))
    parted
    partimage
    pbzip2
    perl
    pigz
    pixz
    procps
    screen
    sshfs
    xz
  ];
  inherit meta;
}
