{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-pie.nix
  ];

  cri.packages = {
    pkgs = {
      latexExam.enable = true;
      thl.enable = mkForce false;
      tiger.enable = mkForce false;
    };
  };

  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-vscode.cpptools
        ms-vscode.cmake-tools
        vscodevim.vim
      ];
    })
  ];

  cri.sddm.title = lib.mkForce "Exam PIE";
}
