{ lib
, fetchurl
, ghc
, stdenv
, which
}:

stdenv.mkDerivation rec {
  pname = "havm";
  version = "0.28";

  src = fetchurl {
    url = "https://www.lrde.epita.fr/~tiger/download/${pname}-${version}.tar.gz";
    sha256 = "sha256-DtpW2mtve93hAWanWHSozYG4R/fOgvsbaaAItCNQx68=";
  };

  nativeBuildInputs = [
    ghc
  ];

  checkInputs = [
    which
  ];

  doCheck = true;
  doInstallCheck = true;

  meta = with lib; {
    description = "HAVM, virtual machine designed to execute simple register based
high level intermediate code";
    homepage = "https://www.lrde.epita.fr/wiki/Havm";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
