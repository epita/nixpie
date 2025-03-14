{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "dash_daq";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-odhbZ5n3uIVlL7xErr21jEElRhao01C5Q77rQq3kJWo=";
  };

  propagatedBuildInputs = [
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/plotly/dash-daq";
    description = "DAQ components for Dash.";
    license = licenses.mit;
  };
}
