{ lib, stdenv, fetchurl, extraThemeConfig ? "" }:

let
  themes = [ "epita-simplyblack" "epita-acu-2023" ];
in
stdenv.mkDerivation {
  pname = "sddm-epita-themes";
  version = "1.0-2";

  src = fetchurl {
    url = "http://static.cri.epita.net/pkg/epita-themes-sddm.tgz";
    sha256 = "o12U7GHXoyqVKiTOgYf0ElmfHeArMHuLuyLHkePn+Ic=";
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
