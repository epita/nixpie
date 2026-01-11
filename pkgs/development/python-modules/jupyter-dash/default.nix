{ lib, buildPythonPackage, fetchPypi, flask, ipykernel, ipython, retrying, requests, ansi2html, dash, setuptools }:

buildPythonPackage rec {
  pname = "jupyter-dash";
  version = "0.4.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-1UbHwlooZ8FMlaSK8K1XKAOyaRWlzmBSFYyd7eTb9Iw=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [ flask ipykernel ipython retrying requests ansi2html dash ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/plotly/jupyter-dash";
    description = "Dash support for the Jupyter notebook interface";
    license = licenses.mit;
  };
}
