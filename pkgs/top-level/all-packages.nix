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

  ipxe-forge = ../tools/ipxe-forge;

  ### TOOLS

  clonezilla = ../tools/backup/clonezilla;

  ### DEVELOPMENT / COMPILERS

  clang32-alias = ../development/compilers/clang32-alias;

  reflex = ../development/compilers/reflex;

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

  dirbuster = ../development/tools/dirbuster;

  pharaoh = ../development/tools/pharaoh;

  ### DEVELOPMENT / PYTHON MODULES

  jupyter-dash = {
    path = ../development/python-modules/jupyter-dash;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  jupyter_latex_envs = {
    path = ../development/python-modules/jupyter_latex_envs;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  nbtranslate = {
    path = ../development/python-modules/nbtranslate;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  ### DEVELOPMENT / LIBRARIES

  libfff = ../development/libraries/libfff;

  spot-lrde = ../development/libraries/spot-lrde;

  ### OS-SPECIFIC

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
