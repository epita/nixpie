{ pkgs, ... }:

{
  cri.programs.packageBundles.dev = with pkgs; [
    # build systems
    autoconf
    autoconf-archive
    automake
    cmake
    gnumake

    # compilers
    clang
    gcc
    llvm

    # misc
    bintools
    capstone
    check
    checkbashisms
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
    pkg-config
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
}
