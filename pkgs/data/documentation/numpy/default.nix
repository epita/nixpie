{ lib, stdenv, fetchzip }:

stdenv.makeDerivation rec {
  pname = "numpy-doc";
  version = "2.2";

  src = fetchzip {
    url = "https://numpy.org/doc/${version}/numpy-html.zip";
    hash = "";
  };

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';

  meta = with lib; {
    description = "NumPy Documentation for version ${version}";
    homepage = "https://numpy.org/doc/{version}/numpy-html.zip";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}

