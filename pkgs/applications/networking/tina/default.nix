{ stdenv
, lib
, fetchurl
, makeWrapper
, autoPatchelfHook
, makeDesktopItem
, copyDesktopItems
, lndir
, buildFHSUserEnvBubblewrap
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
, xorg
}:

let
  version = "3.8.5";
  
  src = fetchurl {
    url = "https://projects.laas.fr/tina/binaries/tina-${version}-amd64-linux.tgz";
    sha256 = "sha256-lWnElPO4fEEWYTTf+XRykTkkhYV2hn53D5Z0TckcJ9Y=";
  };
  
  tinaFiles = stdenv.mkDerivation {
    pname = "tina-files";
    inherit version src;
    
    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];
    
    buildInputs = [
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
    ] ++ (with xorg; [
      libICE
      libSM
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXScrnSaver
      libXtst
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
      xcbutilwm
    ]);
    
    unpackPhase = ''
      mkdir -p $out
      tar -xzf $src -C $out --strip-components=0
    '';
    
    installPhase = ''
      # Create bin directory
      mkdir -p $out/bin
      
      # Create wrapper scripts for all binaries
      for bin in $out/tina-${version}/bin/*; do
        if [ -f "$bin" ] && [ -x "$bin" ]; then
          binName=$(basename "$bin")
          makeWrapper "$bin" "$out/bin/$binName" \
            --prefix LD_LIBRARY_PATH : "$out/tina-${version}/lib"
        fi
      done
    '';
  };
  
  desktopItem = makeDesktopItem {
    name = "tina";
    desktopName = "Tina";
    comment = "Toolbox for the editing and analysis of Petri Nets";
    exec = "nd %f";
    icon = "${tinaFiles}/tina-${version}/doc/html/tina.png";
    categories = [ "Science" "Education" "Development" ];
    mimeTypes = [ "application/x-net" "application/x-ndr" ];
  };
  
  fhs = buildFHSUserEnvBubblewrap {
    name = "tina-fhs";
    runScript = "${tinaFiles}/bin/nd";
    targetPkgs = pkgs: [ libudev0-shim ];
    extraInstallCommands = ''
      mkdir -p "$out/share/applications"
      cp "${desktopItem}/share/applications/"* "$out/share/applications/"
    '';
  };

in stdenv.mkDerivation {
  pname = "tina";
  inherit version;
  
  dontUnpack = true;
  
  nativeBuildInputs = [ copyDesktopItems lndir ];
  
  installPhase = ''
    mkdir -p $out
    ${lndir}/bin/lndir -silent ${fhs} $out
    
    # Create a main launcher script
    cat > $out/bin/tina <<EOF
    #!/bin/sh
    echo "Tina Toolbox ${version}"
    echo "Available tools:"
    echo "  nd      - Net Draw (graphical editor)"
    echo "  ndrio   - Net conversion tools"
    echo "  tina    - State/Graph generation"
    echo "  sift    - State space tools"
    echo "  plan    - Path analysis tools"
    echo "  play    - Step simulator"
    echo "  muse    - Structural analysis"
    echo "  selt    - State/Event LTL model checker"
    echo "  pathto  - Path finder"
    echo "  struct  - Structural bounded model checker"
    echo "  tedd    - State space builder with decision diagrams"
    echo "  walk    - Random walk generator"
    echo "  scan    - Tool"
    echo ""
    EOF
    chmod +x $out/bin/tina
  '';

  desktopItems = [ desktopItem ];
  
  meta = with lib; {
    description = "Tina toolbox for the editing and analysis of Petri Nets";
    homepage = "https://projects.laas.fr/tina/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
