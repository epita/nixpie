{ lib, buildPythonPackage, fetchPypi, beautifulsoup4, requests }:

buildPythonPackage rec {
  pname = "wikipedia";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2w+tGCn91EGxhSMG6YVjmCBNwHhtKZbdLgyLuOJhM7I=";
  };

  doCheck = false;
  propagatedBuildInputs = [ beautifulsoup4 requests ];

  meta = with lib; {
    homepage = "https://github.com/goldsmith/Wikipedia";
    description = "Wikipedia API for Python";
    license = licenses.mit;
  };
}
