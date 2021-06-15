{ lib, stdenv, fetchFromGitHub, coreutils }:

stdenv.mkDerivation rec {
  pname = "term_size";
  version = "903dd84008a5ce4a7740a501d543ccd9935de443";

  src = fetchFromGitHub {
    owner = "epita";
    repo = "term_size";
    rev = version;
    sha256 = "1xxx8hmk0iwklmin5i33nz130qfm0n8kpya2iyq9276rv771415z";
  };

  installPhase = ''
    install -Dm755 $src/term_size $out/bin/term_size

    substituteInPlace $out/bin/term_size \
      --replace printf ${coreutils}/bin/printf
  '';

  meta = with lib; {
    platforms = platforms.unix;
  };
}
