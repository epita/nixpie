{ config, lib, ... }:

{
  imports = [
    ../profiles/exam

    ./nixos-sup.nix
    ./nixos-spe.nix
  ];

  cri.sddm.title = lib.mkForce "Exam Prepa";
  cri.xfce.enable = lib.mkForce false;
}
