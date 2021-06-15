{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "fff";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "meekrosoft";
    repo = "fff";
    rev = "v${version}";
    sha256 = "sha256-EY/Ay44+dlJ41ftioCLylcN0g4WLhOLVeskgmsUwQDQ=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm755 $src/fff.h $out/include/fff.h
  '';

  meta = with lib; {
    platforms = platforms.unix;
  };
}
