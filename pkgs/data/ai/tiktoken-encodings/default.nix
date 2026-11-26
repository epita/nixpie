{ lib, fetchurl, linkFarm }:

# tiktoken encodings, laid out as a tiktoken cache directory in $out/share/tiktoken.
# Point TIKTOKEN_CACHE_DIR to it and tiktoken.get_encoding() works offline.
let
  # tiktoken names each cache file after the sha1 of the URL it comes from
  # (tiktoken/load.py: read_file_cached), hashes from tiktoken_ext/openai_public.py
  encodings = {
    "r50k_base" = "sha256-MGzSfwPBpxTspxCOA9ZrfcBCq+jCWLRMGZp+2YON2TA=";
    "cl100k_base" = "sha256-Ijkht27pm96ZW3/3OFE+7xAPtR0YyTWXoRO8/+hlsqc=";
    "o200k_base" = "sha256-RGqVOMtsNI41FhINfAiwn1fDZJXirP/+WaW/iwz7Gi0=";
  };

  encodingEntry = name: hash:
    let
      url = "https://openaipublic.blob.core.windows.net/encodings/${name}.tiktoken";
    in
    {
      name = "share/tiktoken/${builtins.hashString "sha1" url}";
      path = fetchurl { inherit url hash; };
    };
in
(linkFarm "tiktoken-encodings" (lib.mapAttrsToList encodingEntry encodings)).overrideAttrs {
  meta = with lib; {
    description = "tiktoken BPE encodings (r50k_base, cl100k_base, o200k_base) for offline use";
    homepage = "https://github.com/openai/tiktoken";
    platforms = platforms.all;
    license = licenses.mit;
  };
}
