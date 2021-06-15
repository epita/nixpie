final: prev:

{
  libfff = final.callPackage ./development/libraries/libfff { };
  termSize = final.callPackage ./tools/misc/term-size { };
  sddm-epita-themes = final.callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
}
