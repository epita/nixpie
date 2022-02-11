{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.ocaml.afit.enable = lib.options.mkEnableOption "dev AFIT CRI OCaml package bundle";
  };

  config = lib.mkIf config.cri.packages.ocaml.afit.enable {
    cri.packages.ocamlPackages = with pkgs.ocamlPackages; [
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
  };
}
