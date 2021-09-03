final: prev:

{
  exec-tools = final.callPackage ./exec-tools { };
  libfff = final.callPackage ./development/libraries/libfff { };
  m68k = final.qt5.callPackage ./development/tools/m68k { };
  pam_afs_session = final.callPackage ./os-specific/linux/pam_afs_session { };
  term_size = final.callPackage ./tools/misc/term_size { };
  sddm-epita-themes = final.callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
}
