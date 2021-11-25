{ lib
, writers
, python3Packages
}:

let
  requests-gssapi = python3Packages.buildPythonPackage rec {
    pname = "requests-gssapi";
    version = "1.2.3";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-IHhFCJgUAfcVPJM+7QlTOJM6QIGNplolnb8tgNzLFQ4=";
    };

    propagatedBuildInputs = with python3Packages; [
      gssapi
      requests
    ];
  };
in
(writers.writePython3Bin "exam-start"
  {
    libraries = with python3Packages; [
      gssapi
      requests
      requests-gssapi
      sh
      termcolor
    ];
    flakeIgnore = [ "E265" "E501" ];
  }
  (builtins.readFile ./exam-start)
) // {
  meta = with lib; {
    platforms = platforms.linux;
  };
}
