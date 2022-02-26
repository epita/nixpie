final: prev:

rec {
  # Commented for now. We are hitting https://github.com/pytorch/text/issues/1342
  # torchtext = final.python3Packages.callPackage ./development/python-modules/torchtext { };

  ciscoPacketTracer8 = final.callPackage ./applications/networking/cisco-packet-tracer { };
  clang-format-epita = final.callPackage ./development/tools/clang-format-epita { };
  clonezilla = final.callPackage ./tools/system/clonezilla { };
  exam-start = final.callPackage ./exam-start { };
  exec-tools = final.callPackage ./exec-tools { };
  havm = final.callPackage ./development/tools/havm { };
  intel_nuc_led = final.callPackage ./os-specific/linux/intel_nuc_led { inherit (final.linuxPackages) kernel; };
  jupyter_contrib_core = final.python3Packages.callPackage ./development/python-modules/jupyter_contrib_core { };
  jupyter_contrib_nbextensions = final.python3Packages.callPackage ./development/python-modules/jupyter_contrib_nbextensions { };
  jupyter_highlight_selected_word = final.python3Packages.callPackage ./development/python-modules/jupyter_highlight_selected_word { };
  jupyter_latex_envs = final.python3Packages.callPackage ./development/python-modules/jupyter_latex_envs { };
  jupyter_nbextensions_configurator = final.python3Packages.callPackage ./development/python-modules/jupyter_nbextensions_configurator { };
  libfff = final.callPackage ./development/libraries/libfff { };
  m68k = final.qt5.callPackage ./development/tools/m68k { };
  nixpie-utils = final.callPackage ./nixpie-utils { };
  nolimips = final.callPackage ./development/tools/nolimips { };
  nswrappers = final.callPackage ./nswrappers { };
  pam_afs_session = final.callPackage ./os-specific/linux/pam_afs_session { };
  pam_subuid = final.callPackage ./os-specific/linux/pam_subuid { };
  pharaoh = final.callPackage ./development/tools/pharaoh { };
  sddm-epita-themes = final.callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
  squarify = final.python3Packages.callPackage ./development/python-modules/squarify { };
  term_size = final.callPackage ./tools/misc/term_size { };
  wikipedia = final.python3Packages.callPackage ./development/python-modules/wikipedia { };
}
