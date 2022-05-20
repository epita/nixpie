{ lib
, runCommand
, pkgsi686Linux
}:

let
  clang32 = pkgsi686Linux.llvmPackages_11.clang;
in
(runCommand "clang32-alias" { } ''
  mkdir -p $out/bin
  for f in ${clang32}/bin/*
  do
    ln -s $f $out/bin/$(basename $f)32
  done
'').overrideAttrs (old: {
  meta = with lib; {
    platforms = platforms.unix;
  };
})
