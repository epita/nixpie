{ lib, buildPythonPackage, fetchFromGitHub, nbformat, polib }:

buildPythonPackage rec {
  pname = "nbtranslate";
  version = "20161213";

  src = fetchFromGitHub {
    owner = "devrt";
    repo = "nbtranslate";
    rev = "5bfbfac5213158475ef6ff41101c25ff14b9cc6c";
    sha256 = "sha256-4X+MN5IO/o4wYt4Qn8TWP3y3tdcQZxoVOeMZHzvzIOg=";
  };

  propagatedBuildInputs = [ nbformat polib ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/devrt/nbtranslate";
    description = "Translate content of jupyter notebook using gettext tools";
    license = licenses.bsd3;
  };
}
