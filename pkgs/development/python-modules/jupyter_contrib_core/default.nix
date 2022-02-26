{ lib, buildPythonPackage, fetchPypi, notebook, traitlets, tornado }:

buildPythonPackage rec {
  pname = "jupyter_contrib_core";
  version = "0.3.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-5lvA6TL/MYAQA87xYKRmXygS7+JqU4AZJaY0c16aV5Q=";
  };

  propagatedBuildInputs = [ notebook traitlets tornado ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/jupyter-contrib/jupyter_contrib_core";
    description = "Common utilities for jupyter-contrib projects.";
    license = licenses.bsd3;
  };
}
