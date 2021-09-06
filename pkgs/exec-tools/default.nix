{ lib
, stdenv
, coreutils
, e2fsprogs
, gnugrep
, gptfdisk
, htop
, util-linux
}:

stdenv.mkDerivation {
  name = "exec-tools";

  phases = [ "installPhase" "fixupPhase" ];

  preferLocalBuild = true;

  src = ./.;

  installPhase = ''
    install -Dm755 $src/htop.sh $out/bin/htop.sh
    substituteInPlace $out/bin/htop.sh \
      --subst-var-by htop_bin ${htop}/bin/htop

    install -Dm755 $src/set_bootcache.sh $out/bin/set_bootcache.sh
    substituteInPlace $out/bin/set_bootcache.sh \
      --subst-var-by lsblk_bin ${util-linux}/bin/lsblk \
      --subst-var-by grep_bin ${gnugrep}/bin/grep \
      --subst-var-by wc_bin ${coreutils}/bin/wc \
      --subst-var-by cut_bin ${coreutils}/bin/cut \
      --subst-var-by sgdisk_bin ${gptfdisk}/bin/sgdisk \
      --subst-var-by partx_bin ${util-linux}/bin/partx \
      --subst-var-by mkfs.ext4_bin ${e2fsprogs}/bin/mkfs.ext4

    install -Dm755 $src/clear_bootcache.sh $out/bin/clear_bootcache.sh
    substituteInPlace $out/bin/clear_bootcache.sh \
      --subst-var-by mkfs.ext4_bin ${e2fsprogs}/bin/mkfs.ext4

    install -Dm755 $src/vm_prepare_disk.sh $out/bin/vm_prepare_disk.sh
    substituteInPlace $out/bin/vm_prepare_disk.sh \
      --subst-var-by lsblk_bin ${util-linux}/bin/lsblk \
      --subst-var-by grep_bin ${gnugrep}/bin/grep \
      --subst-var-by wc_bin ${coreutils}/bin/wc \
      --subst-var-by cut_bin ${coreutils}/bin/cut \
      --subst-var-by sgdisk_bin ${gptfdisk}/bin/sgdisk \
      --subst-var-by partx_bin ${util-linux}/bin/partx \
      --subst-var-by mkfs.ext4_bin ${e2fsprogs}/bin/mkfs.ext4 \
      --subst-var-by mkswap_bin ${util-linux}/bin/mkswap
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
