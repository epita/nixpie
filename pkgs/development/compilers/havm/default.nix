{ lib
, fetchgit
, stdenv
, autoconf271
, automake
, ghc
, texinfo
, which
}:

stdenv.mkDerivation rec {
  pname = "havm";
  version = "0.28";

  src = fetchgit {
    url = "https://gitlab.lre.epita.fr/tiger/havm.git";
    rev = "53dca210b8c43ae8d64046e0ebf66b6a0eaf168c";
    sha256 = "sha256-Nw8erEKNNObj3WmnDAT8hlXKkA8Bev7Du33FsbHLb5Q=";
  };

  enableParallelBuilding = true;

  preConfigure = ''
    ./bootstrap
  '';

  nativeBuildInputs = [
    autoconf271
    automake
    ghc
    texinfo
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
    platforms = platforms.all;
  };
}
