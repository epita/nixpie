{ lib, buildPythonPackage, fetchPypi, nbconvert, notebook, traitlets, tornado, lxml, jupyter_contrib_core, jupyter_highlight_selected_word, jupyter_latex_envs, jupyter_nbextensions_configurator, pyyaml }:

buildPythonPackage rec {
  pname = "jupyter_contrib_nbextensions";
  version = "0.5.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-7s0o7ML8QQImwKPUky7S+sSGDM+NnpsbKVSINaNbIqs=";
  };

  propagatedBuildInputs = [ nbconvert notebook traitlets tornado lxml jupyter_contrib_core jupyter_highlight_selected_word jupyter_latex_envs jupyter_nbextensions_configurator pyyaml ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/ipython-contrib/jupyter_contrib_nbextensions";
    description = "A collection of Jupyter nbextensions.";
    license = licenses.bsd3;
  };
}
