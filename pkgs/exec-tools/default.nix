{ lib
, stdenvNoCC
, makeWrapper
, clonezilla
, coreutils
, e2fsprogs
, gawk
, gnugrep
, gnused
, gptfdisk
, htop
, nfs-utils
, parted
, util-linux
}:

stdenvNoCC.mkDerivation {
  name = "exec-tools";

  phases = [ "installPhase" "fixupPhase" ];

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 --target-directory=$out/bin/ $src/*.sh

    for script in $out/bin/*.sh; do
      wrapProgram $script \
        ${lib.concatMapStringsSep " \\\n" (pkg: "--prefix PATH : ${lib.getBin pkg}/bin") [
          clonezilla
          coreutils
          e2fsprogs
          gawk
          gnugrep
          gnused
          gptfdisk
          htop
          nfs-utils
          parted
          util-linux
        ]}
    done
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
