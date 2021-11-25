{ pkgs, ... }:

{
  cri.programs.packageBundles.devAfit = with pkgs; [
    dune_2
    gmp
  ];

  cri.programs.ocamlPackageBundles.devAfit = with pkgs.ocamlPackages; [
    alcotest
    astring
    cmdliner
    fmt
    junit
    junit_alcotest
    ocaml-syntax-shims
    ocamlbuild
    ptime
    re
    result
    seq
    stdlib-shims
    topkg
    tyxml
    uchar
    uuidm
    uutf
    zarith
  ];
}
