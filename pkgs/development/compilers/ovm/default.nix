{ lib
, fetchFromGitLab
, ocamlPackages
, ocaml
}:

ocamlPackages.buildDunePackage rec {
  pname = "ovm";
  version = "0.1-20250323";

  src = fetchFromGitLab {
    domain = "gitlab.lre.epita.fr";
    owner = "tiger";
    repo = "ovm";
    rev = "7eab104a541baf96a5249e3861b7a9aba4414461";
    sha256 = "sha256-uCbvKN/3ppdzekh7l4QHKMCvpfgZJD88nSR6ikj9HZc";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    ocamlPackages.menhir
  ];

  buildInputs = [
    ocamlPackages.dune-build-info
  ];

  duneVersion = "3";
  doCheck = lib.versionAtLeast ocaml.version "5.21";

  meta = with lib; {
    description = "OVM (Virtual Machine for Tree Language)";
    homepage = "https://gitlab.lre.epita.fr/tiger/ovm";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
