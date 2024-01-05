{ config, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-majeures.nix
  ];

  cri.packages = {
    pkgs = {
      latexExam.enable = true;
    };
  };

  cri.sddm.title = lib.mkForce "Exam Majeures";
}
