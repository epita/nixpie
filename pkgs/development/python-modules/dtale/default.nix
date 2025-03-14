{ lib, buildPythonPackage, fetchPypi, flask-compress, dash-bootstrap-components, strsimpy, dash-colorscales, dash-daq, missingno, statsmodels }:

buildPythonPackage rec {
  pname = "dtale";
  version = "3.16.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-94utfwFCwJhLn9rNIoNQ0b7hcbKWiIN3w3N462Z3ek8=";
  };

  propagatedBuildInputs = [
    flask-compress
    dash-bootstrap-components
    strsimpy
    dash-colorscales
    dash-daq
    missingno
    statsmodels
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/man-group/dtale";
    description = "Web Client for Visualizing Pandas Objects";
    license = licenses.lgpl21Only;
  };
}
