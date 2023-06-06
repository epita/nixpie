{ config, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-scia.nix
  ];

  cri.sddm.title = lib.mkForce "Exam SCIA";
}
