{ lib, stdenv, autoPatchelfHook, qtbase, wrapQtAppsHook, libdrm, mesa }:

stdenv.mkDerivation rec {
  pname = "m68k";
  version = "1.0";

  src = builtins.fetchTarball {
    url = "http://static.cri.epita.fr/pkg/TP_68000_Ubuntu64.tar.gz";
    sha256 = "sha256:0c4h0ydc2lb8lxq98raa4rcf5abwzi5z0xnm1kgaab9rfbv5grq3";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapQtAppsHook ];
  buildInputs = [ qtbase libdrm mesa ];

  installPhase = ''
    cd $src/68000
    find -type f -not -name '*.so*' -exec install -Dm755 "{}" "$out/bin/{}" \;
    find -type f -name '*.so*' -exec install -Dm644 "{}" "$out/lib/{}" \;
    cd $src/editor
    find -type f -exec install -Dm644 "{}" "$out/share/geany/filedefs/{}" \;
  '';

  preFixup = ''
    sed -i 's/appname=.*/appname=d68k/' "$out/bin/d68k.sh"
    wrapQtApp "$out/bin/d68k.sh"

    sed -i "s,~/68000,$out/bin,g" "$out/share/geany/filedefs/filetypes.asm"
  '';


  meta = with lib; {
    homepage = "http://www.debug-pro.com/epita/archi/s3/fr/";
    description = "Geany plugin to program and emulate execution of Motorola 68000 applications";
    platforms = platforms.linux;
  };
}
