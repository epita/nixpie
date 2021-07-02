{ lib
, stdenv
, util-linux
, gnugrep
, coreutils
, gptfdisk
, e2fsprogs
}:

stdenv.mkDerivation {
  name = "exec-tools";

  phases = [ "installPhase" "fixupPhase" ];

  preferLocalBuild = true;

  src = ./.;

  installPhase = ''
    install -Dm755 $src/set_bootcache.sh $out/bin/set_bootcache.sh

    substituteInPlace $out/bin/set_bootcache.sh \
      --subst-var-by lsblk_bin ${util-linux}/bin/lsblk \
      --subst-var-by grep_bin ${gnugrep}/bin/grep \
      --subst-var-by wc_bin ${coreutils}/bin/wc \
      --subst-var-by cut_bin ${coreutils}/bin/cut \
      --subst-var-by sgdisk_bin ${gptfdisk}/bin/sgdisk \
      --subst-var-by partx_bin ${util-linux}/bin/partx \
      --subst-var-by mkfs.ext4_bin ${e2fsprogs}/bin/mkfs.ext4
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
