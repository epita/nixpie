{ lib
, fetchurl
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "nolimips";
  version = "0.11";

  src = fetchurl {
    url = "https://www.lrde.epita.fr/~tiger/download/${pname}-${version}.tar.gz";
    sha256 = "3a36df701c0266d14fd2eb33f185c0d2537cc6cd234b8235f66921f69ed51dcf";
  };

  doCheck = true;
  doInstallCheck = true;

  meta = with lib; {
    description = "Nolimips, basic MIPS architecture simulator";
    homepage = "https://www.lrde.epita.fr/wiki/Nolimips";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
