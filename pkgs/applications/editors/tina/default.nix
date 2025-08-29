{ stdenv
, lib
, fetchurl
, makeWrapper
, autoPatchelfHook
, makeDesktopItem
, copyDesktopItems
, lndir
, buildFHSEnv
, alsa-lib
, dbus
, dpkg
, expat
, fontconfig
, glib
, libdrm
, libglvnd
, libpulseaudio
, libudev0-shim
, libxkbcommon
, libxml2
, libxslt
, nspr
, nss
, tcl-8_5
, tk-8_5
, xorg
}:
let
  version = "3.8.5";

  src = fetchurl {
    url = "https://projects.laas.fr/tina/binaries/tina-${version}-amd64-linux.tgz";
    sha256 = "sha256-PsGqutHACpwG3HqVKXWZEWRdvjfbF3zIFqtgD1j+zKA=";
  };

  # Tina files with patch elf
  tinaPatched = stdenv.mkDerivation {
    pname = "tina-patched";
    inherit version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    unpackPhase = ''
      tar -xvf $src --strip-components=1
    '';
    installPhase = ''
      mkdir -p $out
      cp -r bin lib $out

      for bin in $out/bin/*; do
        bname=$(basename "$bin")
        if [ -f "$bin" ] && [ -x "$bin" ] && [ "$bname" != "nd" ]; then
          wrapProgram "$bin" \
            --prefix LD_LIBRARY_PATH : "$out/lib"
        fi
      done

      mkdir $out/share
      cp -r doc $out/share
      cp -r nets $out/share
    '';
  };

  # Unpack Tina nd binary without patch elf
  tinaUnpatched = stdenv.mkDerivation {
    pname = "tina-unpatched";
    inherit version src;

    dontFixup = true;

    unpackPhase = ''
      tar -xvf $src --strip-components=1
    '';

    installPhase = ''
      mkdir -p $out
      cp -r bin lib $out
      mkdir $out/share
      cp -r doc nets $out/share
    '';
  };

  # ND FHS environment
  ndFhs = buildFHSEnv {
    name = "nd";
    targetPkgs = pkgs: with pkgs; [
      tinaUnpatched
      alsa-lib
      dbus
      expat
      fontconfig
      glib
      libdrm
      libglvnd
      libpulseaudio
      libudev0-shim
      libxkbcommon
      libxml2
      libxslt
      nspr
      nss
      tcl-8_5
      tk-8_5
      xorg.libICE
      xorg.libSM
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXtst
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilwm
    ];

    runScript = lib.escapeShellArgs [ "/usr/bin/nd" ];
  };
in
stdenv.mkDerivation {
  pname = "tina";
  inherit version;
  dontUnpack = true;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  installPhase = ''
    mkdir -p $out/bin
    for bin in ${tinaPatched}/bin/*; do
      bname=$(basename "$bin")
      if [ -f "$bin" ] && [ -x "$bin" ] && [ "$bname" != "nd" ]; then
        ln -s "${tinaPatched}/bin/$bname" "$out/bin/$bname"
      fi
    done
    ln -s ${ndFhs}/bin/nd $out/bin/nd
    ln -s ${tinaPatched}/share $out/share
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "nd";
      desktopName = "Tina NetDraw";
      comment = "Toolbox for the editing and analysis of Petri Nets";
      exec = "nd %f";
      icon = "tina";
      categories = [ "Science" "Education" "Development" ];
      mimeTypes = [ "application/x-net" "application/x-ndr" ];
    })
  ];

  meta = with lib; {
    description = "Tina toolbox for the editing and analysis of Petri Nets";
    homepage = "https://projects.laas.fr/tina/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
