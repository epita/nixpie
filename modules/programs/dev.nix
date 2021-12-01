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
    # Putting gcc before clang means that `which cc` will be `gcc` instead of `clang`
    gcc
    clang_12
    llvmPackages_12.llvm
    llvmPackages_12.lld

    # testing frameworks
    criterion
    gtest

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
    ipython
    pytest
  ];
}
