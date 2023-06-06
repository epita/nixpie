{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.scala.enable = lib.options.mkEnableOption "dev Scala CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.scala.enable {
    environment.systemPackages = with pkgs; [
      jetbrains.idea-ultimate
      maven
      sbt
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
          scala-lang.scala
        ];
      })
    ];

    programs.java = {
      enable = true;
      package = pkgs.jdk11;
    };
  };
}
