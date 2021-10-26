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
  version = "3.35.2";

  meta = with lib; {
    description = "ncurses partition and disk imaging/cloning program";
    homepage = "https://clonezilla.org";
    license = licenses.gpl2;
    maintainers = with maintainers; [ risson ];
    platforms = platforms.linux;
  };

  clonezilla = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "http://free.nchc.org.tw/drbl-core/src/stable/${pname}-${version}.tar.xz";
      sha256 = "sha256-+p2D108ioZk1kMhcdz7Hw3S5sNKxqGWONlFx+AvumC4=";
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
    version = "2.30.5";

    src = fetchurl {
      url = "http://free.nchc.org.tw/drbl-core/src/stable/${pname}-${version}.tar.xz";
      sha256 = "sha256-pYVrbv/vnfJIjC6E1Hzqw0QP70+P1AcdroT63HhBfjA=";
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
      maintainers = with maintainers; [ risson ];
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
    lvm2
    lzop
    ntfs3g
    (partclone.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ ncurses ];
      configureFlags = old.configureFlags ++ [ "--enable-ncursesw" ];
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
