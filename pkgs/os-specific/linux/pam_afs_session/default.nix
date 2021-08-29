{ lib, stdenv, fetchurl, pam, libkrb5 }:

stdenv.mkDerivation rec {
  pname = "pam-afs-session";
  version = "2.6";

  src = fetchurl {
    url = "https://archives.eyrie.org/software/afs/${pname}-${version}.tar.gz";
    sha256 = "sha256-v2wqYKB57FORfSaKl9Awc15hiftWkA01xvawGRtd/MU=";
  };

  buildInputs = [ pam libkrb5 ];

  meta = with lib; {
    homepage = "https://www.eyrie.org/~eagle/software/pam-afs-session/";
    platforms = platforms.linux;
    license = licenses.bsd3;
  };
}
