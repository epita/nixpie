{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam
    ./nixos-maths.nix
  ];

  cri.packages = {
    pkgs = {
      latexExam.enable = true;
    };
  };

  cri.sddm.title = lib.mkForce "Exam Maths";
}
