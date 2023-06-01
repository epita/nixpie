{ stdenv, lib, fetchurl, makeWrapper, jre }:
stdenv.mkDerivation rec {
  pname = "DirBuster";
  version = "1.0-RC1";

  src = fetchurl {
    url = "mirror://sourceforge/dirbuster/${pname}%20%28jar%20%2B%20lists%29/${version}/${pname}-${version}.tar.bz2";
    sha256 = "sha256-UoEt1NkaLsKux3lr+AB+TZCCshQs2hIo63igT39V68E=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -pv $out/share/java $out/bin

    cp *.jar $out/share/java/
    cp -r lib $out/share/java/

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/java/${pname}-${version}.jar"
  '';

  meta = {
    description = "multi threaded brute force web discovery application";
    homepage = "https://sourceforge.net/projects/dirbuster/";
    license = with lib.licenses; [ gpl2 ];
    platforms = lib.platforms.unix;
  };
}
