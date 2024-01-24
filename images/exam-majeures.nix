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
      libvirt.enable = lib.mkForce false;
      libvirt.enableDiskPartition = lib.mkForce false;
    };
  };

  cri.sddm.title = lib.mkForce "Exam Majeures";
}
