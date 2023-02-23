{ lib
, fetchgit
, stdenv
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "nolimips";
  version = "0.11";

  src = fetchgit {
    url = "https://gitlab.lre.epita.fr/tiger/nolimips.git";
    rev = "d116bc9efe62aa2d86bb9f24c956a29fc68e6919";
    sha256 = "sha256-WAZlIgApe8nLdCQ6EyJX4PAqwQzf0se8rjjeQfiPwH8=";
  };

  enableParallelBuilding = true;

  preConfigure = ''
    patchShebangs --build ./dev/
    patchShebangs --build ./doc/
    patchShebangs --build ./src/inst/
    patchShebangs --build ./src/parse/
    ./bootstrap
  '';

  nativeBuildInputs = with pkgs; [
    libtool
    autoconf
    autoconf-archive
    automake
    gnum4
    bison
    flex
    clang
    texinfo
    python3
    perl
  ];

  doCheck = true;
  doInstallCheck = true;

  meta = with lib; {
    description = "Nolimips, basic MIPS architecture simulator";
    homepage = "https://www.lrde.epita.fr/wiki/Nolimips";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
