{ pkgsUnstable, pkgsMaster }:

final: prev: {
  cudatoolkit = (pkgsUnstable.cudatoolkit_11_4.override {
    gcc = final.stdenv.cc;
  }).overrideAttrs (old: {
    postInstall = ''
      ls -la
      pwd
      cd pkg/builds
      mv nsight_compute/ nsight_systems/ $out/
    '';
  });


  inherit (pkgsUnstable)
    chromium
    discord
    firefox
    firefox-unwrapped
    teams
    wrapFirefox
    ;
}
