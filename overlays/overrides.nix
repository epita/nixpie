{ pkgsUnstable, pkgsMaster }:

final: prev: {
  cudatoolkit = (pkgsUnstable.cudatoolkit_11_4.override {
    gcc = final.stdenv.cc;
  }).overrideAttrs (old: rec {
    nativeBuildInputs = old.nativeBuildInputs ++ [ final.libsForQt5.wrapQtAppsHook ];
    buildInputs = old.buildInputs ++ [ final.libsForQt5.full ];
    runtimeDependencies = old.runtimeDependencies ++ [
      final.boost
      final.dbus
      final.libkrb5
      final.libxkbcommon
      final.xorg.libXcomposite
      final.xorg.libXcursor
      final.xorg.libXdamage
      final.xorg.libXfixes
      final.xorg.libXrandr
      final.xorg.libxcb
      final.xorg.xcbutil
      final.xorg.xcbutilimage
      final.xorg.xcbutilkeysyms
      final.xorg.xcbutilrenderutil
      final.xorg.xcbutilwm
      final.nss
      final.nspr
      final.linuxPackages.nvidia_x11
    ];
    rpath = "${final.lib.makeLibraryPath runtimeDependencies}:${final.stdenv.cc.cc.lib}/lib64";
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
  });

  inherit (pkgsUnstable)
    chromium
    discord
    firefox
    firefox-unwrapped
    teams
    wrapFirefox
    ;
}
