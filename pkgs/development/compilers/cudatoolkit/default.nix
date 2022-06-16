{ lib
, stdenv
, libsForQt5
, boost
, dbus
, libkrb5
, libxkbcommon
, xorg
, nss
, nspr
, linuxPackages
, cudaPackages_11_5
}:

(cudaPackages_11_5.cudatoolkit.override (old: rec {
  gcc = stdenv.cc;
})).overrideAttrs (old: rec {
  nativeBuildInputs = old.nativeBuildInputs ++ [ libsForQt5.wrapQtAppsHook ];
  buildInputs = old.buildInputs ++ [ libsForQt5.full ];
  runtimeDependencies = old.runtimeDependencies ++ [
    boost
    dbus
    libkrb5
    libxkbcommon
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    nss
    nspr
    linuxPackages.nvidia_x11
  ];
  rpath = "${lib.makeLibraryPath runtimeDependencies}:${stdenv.cc.cc.lib}/lib64";
  dontWrapQtApps = true;
  postInstall = ''
    cd pkg/builds
    mv nsight_compute/ nsight_systems/ $out/
  '';
  preFixup = old.preFixup + ''
    while IFS= read -r -d ''$'\0' i; do
      if ! isELF "$i"; then continue; fi
      echo "patching $i..."
      if [[ ! $i =~ \.so ]]; then
        patchelf \
          --set-interpreter "''$(cat $NIX_CC/nix-support/dynamic-linker)" $i
      fi
      rpath2=$out/nsight_compute/host/linux-desktop-glibc_2_11_3-x64:$rpath
      patchelf --set-rpath "$rpath2" --force-rpath $i
    done < <(find $out/nsight_compute/host/linux-desktop-glibc_2_11_3-x64 -type f -print0)

    while IFS= read -r -d ''$'\0' i; do
      if ! isELF "$i"; then continue; fi
      echo "patching $i..."
      if [[ ! $i =~ \.so ]]; then
        patchelf \
          --set-interpreter "''$(cat $NIX_CC/nix-support/dynamic-linker)" $i
      fi
      rpath2=$out/nsight_systems/host-linux-x64:$rpath
      patchelf --set-rpath "$rpath2" --force-rpath $i
    done < <(find $out/nsight_systems/host-linux-x64 -type f -print0)

    wrapQtApp "$out/nsight_compute/host/linux-desktop-glibc_2_11_3-x64/ncu-ui.bin"
    wrapQtApp "$out/nsight_systems/host-linux-x64/nsys-ui.bin"
  '';

  postFixup = old.postFixup + ''
    addOpenGLRunpath --force-rpath $out/{nsight_compute/host/linux-desktop-glibc_2_11_3-x64,nsight_systems/host-linux-x64}/lib*.so
  '';
})
