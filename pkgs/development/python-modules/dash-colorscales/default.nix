{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "dash_colorscales";
  version = "0.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4uuMeOcC0D6cE/t8qIjtICFSSU27BT9aq2QXtvbRn2M=";
  };

  propagatedBuildInputs = [
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/plotly/dash-colorscales";
    description = "Add a fancy colorscale picker to your Dash apps";
    license = licenses.mit;
  };
}
