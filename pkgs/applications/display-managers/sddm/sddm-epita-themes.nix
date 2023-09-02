{ lib, stdenv, fetchurl, extraThemeConfig ? "" }:

let
  themes = [ "epita-simplyblack" "epita-acu-2023" "epita-bde-2024" ];
in
stdenv.mkDerivation rec {
  pname = "sddm-epita-themes";
  version = "1.1.2";

  src = fetchurl {
    url = "https://gitlab.cri.epita.fr/cri/packages/epita-themes-sddm/-/archive/${version}/epita-themes-sddm-${version}.tar.gz";
    sha256 = "sha256-faGf99Ho5XotANwJBOk895QAas0iwN0gwMocaGe2uuA=";
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
