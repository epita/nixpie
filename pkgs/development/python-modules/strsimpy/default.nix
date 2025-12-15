{ lib, buildPythonPackage, fetchPypi, setuptools }:

buildPythonPackage rec {
  pname = "strsimpy";
  version = "0.2.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CELrV/evhsiCpZobyHIewlgKJn5WP9BQPO0pcgQDcsk=";
  };

  build-system = [ setuptools ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/luozhouyang/python-string-similarity";
    description = "A library implementing different string similarity and distance measures";
    license = licenses.bsd3;
  };
}
