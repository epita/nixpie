{ lib, stdenv, fetchzip, python3Packages }:

let
  numpyVersion = builtins.concatStringsSep "." (lib.lists.take 2 (builtins.splitVersion python3Packages.numpy.version));
in
stdenv.mkDerivation rec {
  pname = "numpy-doc";
  version = numpyVersion;

  src = fetchzip {
    url = "https://numpy.org/doc/${version}/numpy-html.zip";
    hash = "sha256-hmENDKgfh8h3OZGq/jO20R+vj0udAg9Ic/8+VzgF4Jw=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  meta = with lib; {
    description = "NumPy Documentation for version ${version}";
    homepage = "https://numpy.org/doc/${version}/";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
