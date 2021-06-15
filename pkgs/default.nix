final: prev:

{
  libfff = final.callPackage ./development/libraries/libfff { };
  termSize = final.callPackage ./tools/misc/term-size { };
  sddmEpitaThemes = final.callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
}
