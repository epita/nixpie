{ config, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-pie.nix
  ];

  cri.programs.packages = with config.cri.programs.packageBundles; [
    latexExam
  ];

  cri.sddm.title = lib.mkForce "Exam PIE";
}
