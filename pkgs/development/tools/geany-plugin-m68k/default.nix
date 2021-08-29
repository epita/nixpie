{ lib, stdenv, autoPatchelfHook, qtbase, wrapQtAppsHook, libdrm, mesa }:

stdenv.mkDerivation rec {
  pname = "geany-plugin-m68k";
  version = "1.0";

  src = builtins.fetchTarball {
    url = "http://static.cri.epita.fr/pkg/TP_68000_Ubuntu64.tar.gz";
    sha256 = "sha256:0c4h0ydc2lb8lxq98raa4rcf5abwzi5z0xnm1kgaab9rfbv5grq3";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapQtAppsHook ];
  buildInputs = [ qtbase libdrm mesa ];

  installPhase = ''
    find 68000 -type f -exec install -Dm755 "{}" "$out/{}" \;
    find editor -type f -exec install -Dm755 "{}" "$out/{}" \;
  '';

  preFixup = ''
    sed -i 's/appname=.*/appname=d68k/' "$out/68000/d68k.sh"
    wrapQtApp "$out/68000/d68k.sh"

    sed -i "s,~/68000,$out/68000,g" "$out/editor/filetypes.asm"
  '';

  meta = with lib; {
    homepage = "http://www.debug-pro.com/epita/archi/s3/fr/";
    description = "Geany plugin to program and emulate execution of Motorola 68000 applications";
    platforms = platforms.linux;
  };
}
