{ config, pkgs, ... }:

let
  franceIOIPkgs = with pkgs; [
    ddd
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-vscode.cpptools
      ];
    })
    thonny
  ];
in
{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "France IOI";
  cri.xfce.enable = true;

  environment.systemPackages = franceIOIPkgs;

  cri.packages = {
    pkgs = {
      dev.enable = true;
      java.enable = true;
    };
  };
}
