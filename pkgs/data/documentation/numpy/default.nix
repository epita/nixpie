{ lib, stdenv, fetchzip, python3Packages }:

let
  numpyVersion = builtins.concatStringsSep "." (lib.lists.take 2 (builtins.splitVersion python3Packages.numpy.version));
in
stdenv.mkDerivation rec {
  pname = "numpy-doc";
  version = numpyVersion;

  src = fetchzip {
    url = "https://numpy.org/doc/${version}/numpy-html.zip";
    hash = "sha256-f1L5rvxnXhj+IIEnp/R2t/8mJx59/cVZpC7CmO9/Tm0=";
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
