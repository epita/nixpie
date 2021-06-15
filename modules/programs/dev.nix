{ pkgs, ... }:

{
  cri.programs.dev = with pkgs; [
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
