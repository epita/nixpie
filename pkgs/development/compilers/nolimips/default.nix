{ lib
, fetchurl
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "nolimips";
  version = "0.11";

  src = fetchurl {
    url = "https://www.lrde.epita.fr/~tiger/download/${pname}-${version}.tar.gz";
    sha256 = "sha256-RPizR991vR+pvSGt1+Coy45cNIMGUgc4vKCI9xB+Bgg=";
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
