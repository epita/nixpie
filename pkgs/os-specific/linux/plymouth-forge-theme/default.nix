{ lib, stdenvNoCC, imagemagick }:

stdenvNoCC.mkDerivation {
  pname = "plymouth-forge-theme";
  version = "0.0.1";

  src = ./.;

  buildPhase = ''
    runHook preBuild
    ${imagemagick}/bin/convert -coalesce logo.gif progress.png
    for image in *.png; do
      ${imagemagick}/bin/convert -negate $image $image.new
      mv $image.new $image
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plymouth/themes/forge
    cp * $out/share/plymouth/themes/forge
    rm $out/share/plymouth/themes/forge/logo.gif
    rm $out/share/plymouth/themes/forge/default.nix

    find $out/share/plymouth/themes -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;

    runHook postInstall
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
