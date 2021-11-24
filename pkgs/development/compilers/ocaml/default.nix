{ lib
, symlinkJoin
, makeWrapper
, ocamlPackages
, ocaml
}:

symlinkJoin rec {
  inherit (ocaml) name meta;
  version = lib.getVersion ocaml;

  paths = [ ocaml ];
  buildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/ocaml \
      --add-flags "-I ${ocamlPackages.findlib}/lib/ocaml/${version}/site-lib"
  '';
}
