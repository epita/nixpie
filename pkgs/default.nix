final: prev:

let
  inherit (final) callPackage;
in
rec {
  # Commented for now. We are hitting https://github.com/pytorch/text/issues/1342
  # torchtext = final.python3Packages.callPackage ./development/python-modules/torchtext { };

  ciscoPacketTracer8 = callPackage ./applications/networking/cisco-packet-tracer { };
  clang-format-epita = callPackage ./development/tools/clang-format-epita { };
  clonezilla = callPackage ./tools/system/clonezilla { };
  exam-start = callPackage ./exam-start { };
  exec-tools = callPackage ./exec-tools { };
  geany = callPackage ./applications/editors/geany { inherit (prev) geany; };
  havm = callPackage ./development/tools/havm { };
  i3lock = callPackage ./applications/window-managers/i3/lock.nix { inherit (prev) i3lock; };
  intel_nuc_led = callPackage ./os-specific/linux/intel_nuc_led { inherit (linuxPackages) kernel; };
  jupyter-dash = python3Packages.callPackage ./development/python-modules/jupyter-dash { };
  jupyter_contrib_core = python3Packages.callPackage ./development/python-modules/jupyter_contrib_core { };
  jupyter_contrib_nbextensions = python3Packages.callPackage ./development/python-modules/jupyter_contrib_nbextensions { };
  jupyter_highlight_selected_word = python3Packages.callPackage ./development/python-modules/jupyter_highlight_selected_word { };
  jupyter_latex_envs = python3Packages.callPackage ./development/python-modules/jupyter_latex_envs { };
  jupyter_nbextensions_configurator = python3Packages.callPackage ./development/python-modules/jupyter_nbextensions_configurator { };
  libfff = callPackage ./development/libraries/libfff { };
  m68k = qt5.callPackage ./development/tools/m68k { };
  nbtranslate = python3Packages.callPackage ./development/python-modules/nbtranslate { };
  nixpie-utils = callPackage ./nixpie-utils { };
  ocaml = callPackage ./development/compilers/ocaml { inherit (prev) ocaml; };
  nolimips = callPackage ./development/tools/nolimips { };
  nswrappers = callPackage ./nswrappers { };
  pam_afs_session = callPackage ./os-specific/linux/pam_afs_session { };
  pam_subuid = callPackage ./os-specific/linux/pam_subuid { };
  pharaoh = callPackage ./development/tools/pharaoh { };
  sddm-epita-themes = callPackage ./applications/display-managers/sddm/sddm-epita-themes.nix { };
  squarify = python3Packages.callPackage ./development/python-modules/squarify { };
  term_size = callPackage ./tools/misc/term_size { };
  wikipedia = python3Packages.callPackage ./development/python-modules/wikipedia { };
}
