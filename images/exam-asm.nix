{ config, pkgs, lib, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam
  ];

  netboot.enable = true;
  cri.sddm.title = lib.mkForce "Exam ASM";

  environment.systemPackages = with pkgs; [
    bintools
    git
  ];
}
