{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/exam

    ./france-ioi.nix
  ];

  cri.sddm.title = lib.mkForce "Exam France IOI";
}
