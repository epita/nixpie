final: prev:

{
  # Commented for now. We are hitting https://github.com/pytorch/text/issues/1342
  # torchtext = final.python3Packages.callPackage ./development/python-modules/torchtext { };

  clang-format-epita = final.callPackage ./development/tools/clang-format-epita { };
  clonezilla = final.callPackage ./tools/system/clonezilla { };
  exec-tools = final.callPackage ./exec-tools { };
  intel_nuc_led = final.callPackage ./os-specific/linux/intel_nuc_led { inherit (final.linuxPackages) kernel; };
  libfff = final.callPackage ./development/libraries/libfff { };
  m68k = final.qt5.callPackage ./development/tools/m68k { };
  nixpie-utils = final.callPackage ./nixpie-utils { };
  pam_afs_session = final.callPackage ./os-specific/linux/pam_afs_session { };
  pharaoh = final.callPackage ./development/tools/pharaoh { };
  sddm-epita-themes = final.callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
  term_size = final.callPackage ./tools/misc/term_size { };
}
