{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.dev.enable = lib.options.mkEnableOption "dev CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.dev.enable {
    cri.packages.python.dev.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      # build systems
      autoconf
      autoconf-archive
      automake
      cmake
      gnumake
      meson
      ninja

      # compilers
      # Putting gcc before clang means that `which cc` will be `gcc` instead of
      # `clang`
      gcc
      # gcc-unwrapped with lower priority than gcc so `gcov` is available and
      # `gcc` is still wrapped
      (lib.setPrio (gcc.meta.priority + 1) gcc-unwrapped)

      clang_12
      llvmPackages_12.llvm
      llvmPackages_12.lld

      # testing frameworks
      criterion
      gtest
      gcovr

      # misc
      bintools
      capstone
      check
      checkbashisms
      clang-format-epita
      clang-tools
      ctags
      dash
      doxygen
      fakeroot
      flex
      gdb
      lcov
      libfff
      ltrace
      pkg-config
      readline
      rr
      shellcheck
      strace
      tk
      valgrind

      # lcov dependencies
      perlPackages.JSON
      perlPackages.PerlIOgzip

      # vcs
      git
      pre-commit
      subversion
      tig
    ];

    environment.variables = {
      ACLOCAL_PATH = "${pkgs.autoconf-archive}/share/aclocal:${pkgs.autoconf}/share/aclocal:${pkgs.automake}/share/aclocal";
    };

  };
}
