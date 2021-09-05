final: prev: {
  ocaml = final.symlinkJoin rec {
    inherit (prev.ocaml) name;
    version = final.lib.getVersion prev.ocaml;

    paths = [ prev.ocaml ];
    buildInputs = [ final.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/ocaml \
        --add-flags "-I ${final.ocamlPackages.findlib}/lib/ocaml/${version}/site-lib"
    '';
  };
}
