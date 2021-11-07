{ pkgs, ... }:

{
  cri.programs.packageBundles.dev = with pkgs; [
    # build systems
    autoconf
    autoconf-archive
    automake
    cmake
    gnumake
    meson
    ninja

    # compilers
    clang_12
    gcc
    llvmPackages_12.llvm

    # misc
    bintools
    capstone
    check
    checkbashisms
    clang-format-epita
    criterion
    ctags
    dash
    doxygen
    fakeroot
    flex
    gdb
    lcov
    libfff
    ltrace
    pharaoh
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

  cri.programs.pythonPackageBundles.dev = pythonPackages: with pythonPackages; [
    pytest
  ];
}
