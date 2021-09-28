{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "pharaoh";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Chewie";
    repo = pname;
    rev = "v${version}";
    sha256 = "UgVb4tth4SQbkI+X+79ptCUZUTdoL6YbvGhGcs5G3bM=";
  };

  cargoSha256 = "qGWyl0lJLDkmNX/yRWYHbSWU/Y3OWdeQ6b8QczB99Os=";

  meta = with lib; {
    homepage = "https://github.com/Chewie/pharaoh";
    description = "A dead simple, no permission needed, functional test runner for command line applications";
    license = licenses.mit;
  };
}
