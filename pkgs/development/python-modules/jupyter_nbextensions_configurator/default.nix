{ lib, buildPythonPackage, fetchPypi, jupyter_contrib_core, notebook, pyyaml, tornado, traitlets }:

buildPythonPackage rec {
  pname = "jupyter_nbextensions_configurator";
  version = "0.4.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-5ehrXZ2Jjh/7MOuwjkrYaWmZ95j+8/8yYte5mQduToM=";
  };

  propagatedBuildInputs = [ jupyter_contrib_core notebook pyyaml tornado traitlets ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/jupyter-contrib/jupyter_nbextensions_configurator";
    description = "jupyter serverextension providing configuration interfaces for nbextensions.";
    license = licenses.bsd3;
  };
}
