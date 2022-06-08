{ config, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-sql.nix
  ];

  cri.sddm.title = lib.mkForce "Exam SQL";
}
