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

  dumptorrent = {
    path = ../by-name/du/dumptorrent/package.nix;
    args = final: prev: { inherit (prev) dumptorrent; };
  };

  salt = {
    path = ../by-name/sa/salt/package.nix;
    args = final: prev: { inherit (prev) salt; };
  };

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

  ovm = ../development/compilers/ovm;

  ### DEVELOPMENT / TOOLS

  clang-format-epita = ../development/tools/clang-format-epita;

  dirbuster = ../development/tools/dirbuster;

  ### DEVELOPMENT / PYTHON MODULES

  missingno = {
    path = ../development/python-modules/missingno;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  dash-daq = {
    path = ../development/python-modules/dash-daq;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  # dash-colorscales = {
  #   path = ../development/python-modules/dash-colorscales;
  #   callPackage = final: prev: final.python3Packages.callPackage;
  # };

  strsimpy = {
    path = ../development/python-modules/strsimpy;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

  dtale = {
    path = ../development/python-modules/dtale;
    callPackage = final: prev: final.python3Packages.callPackage;
  };

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

  ciscoPacketTracer8 = {
    path = ../applications/networking/cisco-packet-tracer;
    args = final: prev: { inherit (prev) ciscoPacketTracer8; };
  };

  tina = ../applications/editors/tina;

  sddm-epita-themes = ../applications/display-managers/sddm/sddm-epita-themes.nix;

  ### NSWRAPPERS

  nswrappers = ../nswrappers;

  ### DATA / DOCUMENTATION

  numpy-doc = ../data/documentation/numpy;
}
