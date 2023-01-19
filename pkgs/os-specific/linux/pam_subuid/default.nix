{ lib, stdenv, fetchFromGitHub, meson, ninja, pam, shadow }:

stdenv.mkDerivation rec {
  pname = "pam_subuid";
  version = "2020-04-30";

  src = fetchFromGitHub {
    owner = "yrro";
    repo = pname;
    rev = "e91b4ac7031e282c448a5469aca0e57022bf2626";
    sha256 = "sha256-cYIKrdAhau2lb2WFyzUQAQuRlKZ4gh8lPnvgftP7RE8=";
  };

  buildInputs = [ pam ];
  nativeBuildInputs = [ meson ninja ];

  prePatch = ''
    substituteInPlace pam.c \
      --replace '"usermod"' '"${shadow}/bin/usermod"'
    substituteInPlace subxid.h \
      --replace 'struct xid xid_' 'extern struct xid xid_'
  '';

  meta = with lib; {
    homepage = "https://github.com/yrro/pam_subuid";
    platforms = platforms.linux;
    license = licenses.isc;
  };
}
