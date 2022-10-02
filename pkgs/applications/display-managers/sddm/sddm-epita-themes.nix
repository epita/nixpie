{ lib, stdenv, fetchurl, extraThemeConfig ? "" }:

let
  themes = [ "epita-simplyblack" "epita-acu-2023" ];
in
stdenv.mkDerivation rec {
  pname = "sddm-epita-themes";
  version = "1.1.1";

  src = fetchurl {
    url = "https://gitlab.cri.epita.fr/cri/packages/epita-themes-sddm/-/archive/${version}/epita-themes-sddm-${version}.tar.gz";
    sha256 = "8a05d60f6c29787f52aa0ad4eae08e9fd40f4bf0c6da3c2535d5272399949f22";
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
