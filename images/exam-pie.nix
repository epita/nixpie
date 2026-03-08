{ config, lib, pkgs, ... }:

with lib;

let
  m2Dir = pkgs.stdenvNoCC.mkDerivation {
    pname = "ing-ing1-java-exam-m2";
    version = "20260307";
    src = pkgs.fetchurl {
      url = "https://s3.cri.epita.fr/cri-nico-uploads/ing-ing1-java-exam-maven.tar.xz";
      sha256 = "sha256-vWVNAm9eD4wAZK5Fn0Gj8Vk7U6Ay2HAihsM5PYdd9Ag=";
    };

    unpackPhase = ''
      tar xvf $src
    '';

    installPhase = ''
      mkdir -p $out/.m2
      cp -v -r repository settings.xml $out/.m2
    '';
  };
  ideaConfig = pkgs.stdenvNoCC.mkDerivation {
    pname = "ing-ing1-java-exam-idea";
    version = "20260308";
    src = pkgs.fetchurl {
      url = "https://s3.cri.epita.fr/cri-nico-uploads/ing-ing1-java-exam-idea.tar.xz";
      sha256 = "sha256-kUepkEEcpOkjOn9K55C7YQfsW0SwBmuY5fHZe0S9it0=";
    };

    unpackPhase = ''
      tar xvf $src
    '';

    installPhase = ''
      mkdir -p $out
      cp -v -r .config .local $out
    '';
  };
  skel = pkgs.stdenvNoCC.mkDerivation {
    pname = "ing-ing1-java-exam-skel";
    version = "20260308";

    buildCommand = ''
      mkdir $out

      for dir in ${lib.strings.escapeShellArgs [ "${m2Dir}/.m2" "${ideaConfig}/.config" "${ideaConfig}/.local" ]} ; do
        cp -v -r "$dir" "$out"
      done
    '';
  };
in
{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-pie.nix
  ];

  cri.packages = {
    pkgs = {
      latexExam.enable = true;
      thl.enable = mkForce false;
      tiger.enable = mkForce false;
    };
  };

  cri.sddm.title = lib.mkForce "Exam PIE";

  security.pam.makeHomeDir.skelDirectory = skel.outPath;
}
