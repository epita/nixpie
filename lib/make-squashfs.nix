{ stdenv
, squashfsTools
, closureInfo

, # The root directory of the squashfs filesystem is filled with the
  # closures of the Nix store paths listed here.
  storeContents ? [ ]
, # Compression parameters.
  # For zstd compression you can use "zstd -Xcompression-level 6".
  comp ? "xz -Xdict-size 100%"
, name ? "nix-store.squashfs"
, # Stage 2 init executable to write in a file in the squashfs to access it
  # from stage one
  stage2Init ? "/init"
}:

stdenv.mkDerivation rec {
  inherit name;

  nativeBuildInputs = [ squashfsTools ];

  buildCommand = ''
    mkdir $out

    closureInfo=${closureInfo { rootPaths = storeContents; }}

    # Also include a manifest of the closures in a format suitable
    # for nix-store --load-db.
    cp $closureInfo/registration nix-path-registration

    echo "${stage2Init}" > stage2Init

    # Generate the squashfs image.
    mksquashfs \
      nix-path-registration stage2Init $(cat $closureInfo/store-paths) \
      $out/${name} \
      -keep-as-directory -all-root -b 1048576 -comp ${comp} \
      -reproducible -no-fragments
  '';
}
