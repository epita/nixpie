final: prev: {
  ocaml = final.stdenv.mkDerivation rec {
    name = prev.ocaml.name;
    version = final.lib.getVersion prev.ocaml;
    nativeBuildInputs = [ final.makeWrapper ];

    buildCommand = ''
      mkdir -p $out/bin
      cp ${prev.ocaml}/bin/* $out/bin/
      rm "$out/bin/ocaml"
      makeWrapper "${prev.ocaml}/bin/ocaml" "$out/bin/ocaml" \
        --add-flags "-I ${final.ocamlPackages.findlib}/lib/ocaml/${version}/site-lib"
    '';
  };
}
