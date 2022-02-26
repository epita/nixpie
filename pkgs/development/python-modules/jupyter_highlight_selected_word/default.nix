{ lib, buildPythonPackage, fetchPypi, nbconvert, notebook, traitlets }:

buildPythonPackage rec {
  pname = "jupyter_highlight_selected_word";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-n6dAQkhZqAeVDKCNK/0oo1FUzTLdbVCsTglQAircDns=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/jcb91/jupyter_highlight_selected_word";
    description = "Jupyter notebook extension that enables highlighting every instance of the current word in the notebook";
    license = licenses.bsd3;
  };
}
