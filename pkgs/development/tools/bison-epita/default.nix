{ fetchurl
, pkgs
}:

pkgs.bison.overrideAttrs (old: rec {
  pname = "${old.pname}-epita";
  version = "3.2.1.52-cd4f7";

  doCheck = true;
  doInstallCheck = true;

  src = fetchurl {
    url = "https://www.lrde.epita.fr/~tiger/download/${old.pname}-${version}.tar.gz";
    sha256 = "ddbfdbd2a05fc09fb5b646185495bc6223c738a907c06424f099b08a6603d9bf";
  };
})
