{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "squarify";
  version = "0.4.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-VAkfatF19/IB+JNFdOZHzhtQ3txHjF/ZaGiOt9dGn5U=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/laserson/squarify";
    description = "Pure Python implementation of the squarify treemap layout algorithm";
    license = licenses.asl20;
  };
}
