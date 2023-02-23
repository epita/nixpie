{ lib
, fetchFromGitHub
, stdenv
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "reflex";
  version = "3.2.11";

  src = fetchFromGitHub {
    owner = "Genivia";
    repo = "RE-flex";
    rev = "bc1985e3088466239f7b5fb8fd6d584f18074d7f";
    sha256 = "sha256-QPX6+qHpsfdUva4mZPmeOkwccklCFnckb6ukNuxPsTU=";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = with pkgs; [
    doxygen
    boost
    autoconf
    automake
  ];

  doCheck = true;
  doInstallCheck = true;

  meta = with lib; {
    description = "RE/flex is a free and open-source alternative to the fast lexical analyzer Flex";
    homepage = "https://www.genivia.com/reflex.html";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
