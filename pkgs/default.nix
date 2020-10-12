_: prev: {
  term_size = prev.callPackage ./tools/misc/term_size { };
  sddm-epita-themes = prev.callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
}
