{ config, lib, pkgs, ... }:

let
  espIdfShell = pkgs.mkShell {
    name = "esp-idf-full-shell";

    buildInputs = with pkgs; [
      esp-idf-full
    ];
  };
  # Okay I spent way too much time on this one and this is the only thing I
  # could come up with. I am sorry for this monstruosity but bear with me
  # because it is a wild ride. The goal here is to have a script that launches a
  # nix shell with esp idf packages but I want the shell and its dependencies to
  # already be built to avoid downloading all the packages at runtime. However,
  # when I specify espIdfShell.drvPath in the script, it adds the derivation
  # itself (instead of its output) as a dependency for the script derivation
  # (because string interpolation adds the Nix store path to the context of the
  # whole string). Because of this, a bunch of unexpected paths end up in the
  # closure of our toplevel NixOS module. These paths appear in the
  # pkgs.closureInfo function but Nix itself does not consider theses paths as
  # real dependencies (I didn't dig the specifics any more). So when we build
  # our final store squashfs, the derivation tries to add these unexpected paths
  # to the archive but Nix does not add them to the build sandbox so everything
  # fails.
  # The solution : remove the context so that the derivation itself doesn't
  # become a dependency. Then I add the derivation output path in the script as
  # in a comment so that the derivation is built and appears in our final store.
  espIdfShellDrvPath = builtins.unsafeDiscardStringContext "${espIdfShell.drvPath}";
  espIdfShellStart = pkgs.writeShellScriptBin "esp-idf-shell" ''
    # nix shell for ${espIdfShell}
    # don't remove above line to enforce derivation build at image build
    ${config.nix.package}/bin/nix develop ${espIdfShellDrvPath}
  '';
in
{
  options = {
    cri.packages.pkgs.ssse.enable =
      lib.options.mkEnableOption "dev SSSE CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.ssse.enable {
    cri.packages.python.ssse.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      arduino
      julia
      kicad-unstable
      liberio
      mosquitto
      nodePackages.node-red
      platformio-core
      sfml
      asio
      jsoncpp
      gnuplot
      tig
      ngspice
      pulseview
      sigrok-cli
      vscodium
      tlaplusToolbox
      espIdfShellStart
      framac
    ];

    environment.etc."security/group.conf".text = ''
      *;*;*;Al0000-2400;dialout
    '';
    security.pam.services.sddm.text = lib.mkBefore ''
      auth  required                    pam_group.so
    '';
  };
}
