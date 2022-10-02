{ lib, stdenv, fetchurl, extraThemeConfig ? "" }:

let
  themes = [ "epita-simplyblack" "epita-acu-2023" ];
in
stdenv.mkDerivation {
  pname = "sddm-epita-themes";
  version = "1.0-2";

  src = fetchurl {
    url = "https://gitlab.cri.epita.fr/cri/packages/epita-themes-sddm/-/archive/master/epita-themes-sddm-master.tar.gz";
    sha256 = "927c005b3700db120edc4588316e4c2a20a4c4678f5adc0fce354ac229043e33";
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
