{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam
  ];

  netboot.enable = true;
  cri.sddm.title = lib.mkForce "Exam Inter";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      sql.enable = true;
      java.enable = true;
    };
  };

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
    package = lib.mkForce pkgs.jdk11;
  };
}
