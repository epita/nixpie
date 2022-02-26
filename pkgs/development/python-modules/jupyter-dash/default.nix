{ lib, buildPythonPackage, fetchPypi, flask, ipykernel, ipython, retrying, requests, ansi2html, dash }:

buildPythonPackage rec {
  pname = "jupyter-dash";
  version = "0.4.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-xkxA3Zp4TKTy32OnuGnDxGPE/qB8VHTOQbfolj5oPZQ=";
  };

  propagatedBuildInputs = [ flask ipykernel ipython retrying requests ansi2html dash ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/plotly/jupyter-dash";
    description = "Dash support for the Jupyter notebook interface";
    license = licenses.mit;
  };
}
