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
    # conf_gmp
    fmt
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

    pkgs.ocamlPackages_junit
    pkgs.ocamlPackages_junit_alcotest
  ];
}
