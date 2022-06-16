/* The top-level package collection of NixPIE.
  * It is sorted by categories corresponding to the folder names
  * in the /pkgs folder. Inside the categories packages are roughly
  * sorted by alphabet.
  * Hint: ### starts category names.
*/
{
  ### NIXPIE

  exam-start = ../nixpie/exam-start;

  exec-tools = ../nixpie/exec-tools;

  nixpie-utils = ../nixpie/nixpie-utils;

  ### TOOLS

  clonezilla = ../tools/backup/clonezilla;

  term_size = ../tools/misc/term_size;

  ### DEVELOPMENT / COMPILERS

  clang32-alias = ../development/compilers/clang32-alias;

  cudatoolkit = {
    path = ../development/compilers/cudatoolkit;
    args = final: prev: { inherit (prev) cudaPackages_11_5; };
  };

  havm = ../development/compilers/havm;

  m68k = {
    path = ../development/compilers/m68k;
    callPackage = final: prev: final.qt5.callPackage;
  };

  nolimips = ../development/compilers/nolimips;

  ocaml = {
    path = ../development/compilers/ocaml;
    args = final: prev: { inherit (prev) ocaml; };
  };

  ### DEVELOPMENT / TOOLS

  clang-format-epita = ../development/tools/clang-format-epita;

  pharaoh = ../development/tools/pharaoh;

  ### DEVELOPMENT / PYTHON MODULES

  jupyter-dash = {
    path = ../development/python-modules/jupyter-dash;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  jupyter_contrib_core = {
    path = ../development/python-modules/jupyter_contrib_core;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  jupyter_contrib_nbextensions = {
    path = ../development/python-modules/jupyter_contrib_nbextensions;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  jupyter_highlight_selected_word = {
    path = ../development/python-modules/jupyter_highlight_selected_word;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  jupyter_latex_envs = {
    path = ../development/python-modules/jupyter_latex_envs;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  jupyter_nbextensions_configurator = {
    path = ../development/python-modules/jupyter_nbextensions_configurator;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  nbtranslate = {
    path = ../development/python-modules/nbtranslate;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  squarify = {
    path = ../development/python-modules/squarify;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  wikipedia = {
    path = ../development/python-modules/wikipedia;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  ### DEVELOPMENT / LIBRARIES

  libfff = ../development/libraries/libfff;

  spot-lrde = ../development/libraries/spot-lrde;

  ### OS-SPECIFIC

  # TODO: move this elsewhere
  intel_nuc_led = {
    path = ../os-specific/linux/intel_nuc_led;
    args = final: prev: { inherit (final.linuxPackages) kernel; };
  };

  pam_afs_session = ../os-specific/linux/pam_afs_session;

  pam_subuid = ../os-specific/linux/pam_subuid;

  ### APPLICATIONS

  geany = {
    path = ../applications/editors/geany;
    args = final: prev: { inherit (prev) geany; };
  };

  i3lock = {
    path = ../applications/window-managers/i3/lock.nix;
    args = final: prev: { inherit (prev) i3lock; };
  };

  ciscoPacketTracer8 = ../applications/networking/cisco-packet-tracer;

  sddm-epita-themes = ../applications/display-managers/sddm/sddm-epita-themes.nix;

  ### NSWRAPPERS

  nswrappers = ../nswrappers;
}
