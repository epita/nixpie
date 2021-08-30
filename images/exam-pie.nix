{ config, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-pie.nix
  ];

  cri.sddm.title = lib.mkForce "Exam PIE";
}
