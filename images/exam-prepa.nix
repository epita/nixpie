{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/exam

    ./nixos-prepa.nix
  ];

  cri.sddm.title = lib.mkForce "Exam Prepa";
}
