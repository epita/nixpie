{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, pandas
, certifi
}:

buildPythonPackage rec {
  pname = "ucimlrepo";
  version = "0.0.7";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TP8/noFDZ91glW2pmazkcxlyN7n85MB+mmied7T/tZo=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    pandas
    certifi
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/uci-ml-repo/ucimlrepo";
    description = "Package to easily import datasets from the UC Irvine Machine Learning Repository";
    license = licenses.mit;
  };
}
