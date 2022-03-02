{ lib, stdenv, fetchurl, libsForQt5, extraThemeConfig ? "" }:

let
  rev = "c691f9648acfbdf98c27eae8824e070df155f99b";
in
stdenv.mkDerivation {
  pname = "sddm-epita-simplyflat";
  version = "20190412";

  src = fetchurl {
    url = "https://gitlab.cri.epita.fr/cri/packages/epita-simplyflat/-/archive/${rev}/epita-simplyflat-${rev}.tar.gz";
    sha256 = "sha256-UVDsKzmSEV36DMJbQGT5H+/qpD1zSuUMmCSpZxzkpZ4=";
  };

  dontWrapQtApps = true;
  propagatedBuildInputs = [ libsForQt5.qt5.qtgraphicaleffects  ];

  unpackPhase = ''
    tar xf $src
  '';

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -r epita-simplyflat-${rev} $out/share/sddm/themes/epita-simplyflat
    echo "${extraThemeConfig}" >> $out/share/sddm/themes/epita-simplyflat/theme.conf
  '';

  meta = with lib; {
    platforms = platforms.unix;
    license = licenses.beerware;
  };
}
