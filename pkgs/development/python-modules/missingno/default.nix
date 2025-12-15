{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, numpy
, matplotlib
, scipy
, seaborn
}:

buildPythonPackage rec {
  pname = "missingno";
  version = "0.5.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SkuqnKn55ODZQCRV3ya2VmMulLmeh/pkwM27vHIoN6w=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    numpy
    matplotlib
    scipy
    seaborn
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/ResidentMario/missingno";
    description = "Missing data visualization module for Python.";
    license = licenses.mit;
  };
}
