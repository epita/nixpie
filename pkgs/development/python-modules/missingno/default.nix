{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "missingno";
  version = "0.5.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SkuqnKn55ODZQCRV3ya2VmMulLmeh/pkwM27vHIoN6w=";
  };

  propagatedBuildInputs = [
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/ResidentMario/missingno";
    description = "Missing data visualization module for Python.";
    license = licenses.mit;
  };
}
