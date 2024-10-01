{ lib, stdenv, fetchurl, extraThemeConfig ? "" }:

let
  themes = [ "epita-simplyblack" "epita-acu-2023" "epita-acu-2024" "epita-acu-2025" ];
in
stdenv.mkDerivation rec {
  pname = "sddm-epita-themes";
  version = "1.3.1";

  src = fetchurl {
    url = "https://gitlab.cri.epita.fr/forge/packages/epita-themes-sddm/-/archive/${version}/epita-themes-sddm-${version}.tar.gz";
    sha256 = "48f202720be5f2bd101e94e8e868a5180ffe9930b90f5cce5a19d20f4b22c2d6";
  };

  unpackPhase = ''
    tar xf $src
  '';

  installPhase = lib.concatMapStrings
    (theme: ''
      install -d $out/share/sddm/themes/${theme}
      install -Dm644 \
        epita-themes-sddm-${version}/${theme}/* \
        $out/share/sddm/themes/${theme}
        echo "${extraThemeConfig}" >> $out/share/sddm/themes/${theme}/theme.conf
    '')
    themes;

  meta = with lib; {
    platforms = platforms.unix;
  };
}
