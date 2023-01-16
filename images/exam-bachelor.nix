{ config, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-bachelor.nix
  ];

  cri.sddm.title = lib.mkForce "Exam Bachelor";
}
