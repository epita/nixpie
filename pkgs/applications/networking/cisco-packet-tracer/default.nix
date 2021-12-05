# Taken from https://github.com/NixOS/nixpkgs/commit/cc0ac2c9d43886a16ef637e9b4811f961e0186d7#diff-10c2d2e2e6f7a758d0843dc7028d43c9b535b9bdb871e2ceff0d17e004c110cb
# to be able to override `src`
{ stdenv
, lib
, alsa-lib
, autoPatchelfHook
, buildFHSUserEnvBubblewrap
, callPackage
, copyDesktopItems
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
, lndir
, makeDesktopItem
, makeWrapper
, nspr
, nss
, fetchurl
, xorg
}:

let
  version = "8.0.1";

  ptFiles = stdenv.mkDerivation {
    name = "PacketTracer8Drv";
    inherit version;

    dontUnpack = true;
    src = fetchurl {
      url = "https://gitlab.cri.epita.fr/cri/infrastructure/nixpie/-/package_files/5572/download";
      sha256 = "7dc810747d330ec33191d198dd399a8ff99bf991a10d27f335475692f2c2bcf8";
    };

    nativeBuildInputs = [
      alsa-lib
      autoPatchelfHook
      dbus
      dpkg
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
      makeWrapper
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

    installPhase = ''
      dpkg-deb -x $src $out
      chmod 755 "$out"
      makeWrapper "$out/opt/pt/bin/PacketTracer" "$out/bin/packettracer" \
        --prefix LD_LIBRARY_PATH : "$out/opt/pt/bin"
      # Keep source archive cached, to avoid re-downloading
      ln -s $src $out/usr/share/
    '';
  };

  desktopItem = makeDesktopItem {
    name = "cisco-pt8.desktop";
    desktopName = "Cisco Packet Tracer 8";
    icon = "${ptFiles}/opt/pt/art/app.png";
    exec = "packettracer8 %f";
    mimeType = "application/x-pkt;application/x-pka;application/x-pkz;";
  };

  fhs = buildFHSUserEnvBubblewrap {
    name = "packettracer8";
    runScript = "${ptFiles}/bin/packettracer";
    targetPkgs = pkgs: [ libudev0-shim ];

    extraInstallCommands = ''
      mkdir -p "$out/share/applications"
      cp "${desktopItem}"/share/applications/* "$out/share/applications/"
    '';
  };
in
stdenv.mkDerivation {
  pname = "ciscoPacketTracer8";
  inherit version;

  dontUnpack = true;

  installPhase = ''
    mkdir $out
    ${lndir}/bin/lndir -silent ${fhs} $out
  '';

  desktopItems = [ desktopItem ];
  nativeBuildInputs = [ copyDesktopItems ];

  meta = with lib; {
    description = "Network simulation tool from Cisco";
    homepage = "https://www.netacad.com/courses/packet-tracer";
    license = licenses.unfree;
    maintainers = with maintainers; [ lucasew ];
    platforms = [ "x86_64-linux" ];
  };
}
