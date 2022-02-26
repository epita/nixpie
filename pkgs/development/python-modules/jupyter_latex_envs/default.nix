{ lib, buildPythonPackage, fetchPypi, nbconvert, notebook, traitlets }:

buildPythonPackage rec {
  pname = "jupyter_latex_envs";
  version = "1.4.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Bwox6y3EiLupg5FYeafCk5JHv1w7Zps5i9s2qbU0OHI=";
  };

  propagatedBuildInputs = [ nbconvert notebook traitlets ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/jfbercher/jupyter_latex_envs";
    description = "(some) LaTeX environments for Jupyter notebook";
    license = licenses.bsd3;
  };
}
