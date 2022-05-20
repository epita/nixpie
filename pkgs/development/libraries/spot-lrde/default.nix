{ lib
, stdenv
, fetchurl
, python3
}:

stdenv.mkDerivation rec {
  pname = "spot-lrde";
  version = "2.10.6";

  src = fetchurl {
    url = "http://www.lrde.epita.fr/dload/spot/spot-${version}.tar.gz";
    sha256 = "sha256-xYjRy1PM6j5ZL5lAKxTC9DZ7NJ7O+OF7bTkd8Ua8i6Q=";
  };

  enableParallelBuilding = true;

  buildInputs = [ python3 ];

  configurePhase = ''
    ./configure --prefix $out
  '';

  meta = with lib; {
    description = "Spot is a C++17 library for LTL, ω-automata manipulation and model checking.";
    homepage = "https://spot.lrde.epita.fr/";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
