{ config, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-pie.nix
  ];

  cri.packages = {
    pkgs = {
      latexExam.enable = true;
      prolog.enable = lib.mkForce false;
    };
  };

  cri.sddm.title = lib.mkForce "Exam PIE";
}
