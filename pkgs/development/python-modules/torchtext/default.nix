# See https://github.com/NixOS/nixpkgs/pull/70655
{ buildPythonPackage
, stdenv
, fetchurl
, fetchPypi
, python
, cmake
, util-linux
, which
, ninja
, tqdm
, requests
, pytorch
, numpy
, six
, lib
, isPy3k
, patchelf
}:

let
  pyVerNoDot = builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion;
  pname = "torchtext";

  srcs = version: {
    x86_64-linux-38 = rec {
      name = "${pname}-${version}-cp38-cp38-manylinux1_x86_64.whl";
      url = "https://files.pythonhosted.org/packages/cp38/t/torchtext/${name}";
      hash = "sha256-G8MCQCBipngRbN/HD+XBwvJXzDQ+oXXc8k+crGORi9Q=";
    };
  };

  unsupported = throw "Unsupported system";
in
buildPythonPackage rec {
  inherit pname;
  version = "0.9.1";
  format = "wheel";

  disabled = !isPy3k;

  src = fetchurl (srcs version)."${stdenv.system}-${pyVerNoDot}" or unsupported;

  nativeBuildInputs = [ patchelf ];

  propagatedBuildInputs = [ tqdm requests pytorch numpy six ];

  postFixup =
    let
      rpath = lib.makeLibraryPath [ stdenv.cc.cc.lib ];
    in
    ''
      find $out/${python.sitePackages}/torchtext -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
        echo "setting rpath for $lib..."
        patchelf --set-rpath "${rpath}:$out/${python.sitePackages}/torchtext" "$lib"
      done
    '';

  pythonImportsCheck = [ "torchtext" ];

  meta = {
    homepage = "https://pytorch.org";
    description = "Data loaders and abstractions for text and NLP";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
