final: prev:

{
  libfff = final.callPackage ./development/libraries/libfff { };
  term_size = final.callPackage ./tools/misc/term_size { };
  sddm-epita-themes = final.callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
}
