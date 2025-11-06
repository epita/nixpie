{ config, lib, ... }:

with lib;

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
}
