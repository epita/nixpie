{ lib, pkgs, buildPythonPackage }:

buildPythonPackage rec {
  pname = "leodagan";
  version = "1.0.0";
  format = "pyproject";

  propagatedBuildInputs = [
    pkgs.poetry
    pkgs.python3
    pkgs.python3Packages.click
    pkgs.python3Packages.click-completion
    pkgs.python3Packages.rich
  ];

  src = builtins.fetchurl {
    url = "https://gitlab.cri.epita.fr/thomas.crambert/leodagan/-/archive/1.0.0/leodagan-1.0.0.tar";
    sha256 = "0yl48q6w6sv0340kh1gw8gwgm5w7d04n13pmzxnrzzw8f80m1kb5";
  };

  meta = with lib; {
    homepage = "https://gitlab.cri.epita.fr/thomas.crambert/leodagan";
    description = "Nétiquette checker, python3-style";
    license = licenses.mit;
  };
}
