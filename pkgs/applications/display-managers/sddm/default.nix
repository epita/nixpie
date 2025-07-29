{ plasma5Packages
, fetchpatch
, withWayland ? false
, withLayerShellQt ? false
, extraPackages ? [ ]
}:

with plasma5Packages;

sddm.override {
  inherit withWayland withLayerShellQt extraPackages;
  unwrapped = sddm.unwrapped.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/sddm/sddm/pull/2103.patch";
        hash = "sha256-HxsurSuGJjkGnC8fAiwipadAgcTUhs7n6fQ1SmvMMGc=";
      })
    ];
  });
}
