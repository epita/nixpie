{ lib
, stdenvNoCC
, makeWrapper
, coreutils
, ethtool
, libpcap
}:

stdenvNoCC.mkDerivation {
  name = "nswrappers";

  phases = [ "installPhase" "fixupPhase" ];

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 --target-directory=$out/bin/ $src/*
    rm $out/bin/default.nix

    for script in $out/bin/*; do
      wrapProgram $script \
        ${lib.concatMapStringsSep " \\\n" (pkg: "--prefix PATH : ${lib.getBin pkg}/bin") [
          coreutils
          ethtool
          libpcap
        ]}
    done
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
