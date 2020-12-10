{ stdenv, fetchurl, extraThemeConfig ? "" }:

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

  installPhase = ''
    install -d $out/share/sddm/themes/epita-simplyblack
    install -Dm644 \
      epita-simplyblack/* \
      $out/share/sddm/themes/epita-simplyblack
    echo "${extraThemeConfig}" >> $out/share/sddm/themes/epita-simplyblack/theme.conf
  '';

  meta = with stdenv.lib; {
    platforms = platforms.unix;
  };
}
