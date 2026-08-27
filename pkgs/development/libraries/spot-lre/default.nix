{ lib
, stdenv
, fetchurl
, python3
}:

stdenv.mkDerivation rec {
  pname = "spot-lre";
  version = "2.15.1";

  src = fetchurl {
    url = "https://www.lre.epita.fr/dload/spot/spot-${version}.tar.gz";
    sha256 = "sha256-ZQE6Lt8/MUhU12GYiBRfUsjdNr/SeJTZ25snLZoWzks=";
  };

  enableParallelBuilding = true;

  buildInputs = [ python3 ];

  configurePhase = ''
    ./configure --prefix $out
  '';

  meta = with lib; {
    description = "Spot is a C++20 library for LTL, ω-automata manipulation and model checking.";
    homepage = "https://spot.lre.epita.fr/";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
