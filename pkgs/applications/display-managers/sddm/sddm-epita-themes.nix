{ lib, stdenv, fetchurl, extraThemeConfig ? "" }:

let
  themes = [ "epita-simplyblack" ];
in
stdenv.mkDerivation {
  pname = "sddm-epita-themes";
  version = "1.0-2";

  src = fetchurl {
    url = "http://static.cri.epita.net/pkg/epita-themes-sddm.tgz";
    sha256 = "0icgbrzh9n5g8y6f3hhyianh3rw2i8igcawp6djzh6kv05fb3k1h";
  };

  unpackPhase = ''
    tar xf $src
  '';

  installPhase = lib.concatMapStrings
    (theme: ''
      install -d $out/share/sddm/themes/${theme}
      install -Dm644 \
        ${theme}/* \
        $out/share/sddm/themes/${theme}
        echo "${extraThemeConfig}" >> $out/share/sddm/themes/${theme}/theme.conf
    '')
    themes;

  meta = with lib; {
    platforms = platforms.unix;
  };
}
