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
