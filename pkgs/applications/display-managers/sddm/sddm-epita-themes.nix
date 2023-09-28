{ lib, stdenv, fetchurl, extraThemeConfig ? "" }:

let
  themes = [ "epita-simplyblack" "epita-acu-2023" "epita-acu-2024" ];
in
stdenv.mkDerivation rec {
  pname = "sddm-epita-themes";
  version = "1.2.1";

  src = fetchurl {
    url = "https://gitlab.cri.epita.fr/cri/packages/epita-themes-sddm/-/archive/${version}/epita-themes-sddm-${version}.tar.gz";
    sha256 = "f05293252ddc2fa7021c122f8f3d87338c5be92604f9787b99f1fa4ef011836c";
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
