{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam
  ];

  netboot.enable = true;
  cri.sddm.title = lib.mkForce "Exam Inter";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev devSQL devJava ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev ];

  # Restore internet access
  networking.firewall.enable = lib.mkForce true;
  networking.nftables.enable = lib.mkForce false;

  # Enable XFCE
  cri.xfce.enable = true;

  environment.systemPackages = with pkgs; [
    dbeaver
    postman
    vscode
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };
}
