{ config, pkgs, system, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri = {
    sddm.title = "NixOS Bachelor";
    xfce.enable = true;

    packages = {
      pkgs = {
        dev.enable = true;
      };
      python = {
        dev.enable = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
      ];
    })
  ];

  cri.packages.pythonPackages.nixosBachelorCustom = p: with p; [
    numpy
    pandas
    scikit-learn
    matplotlib
    networkx
  ];
}
