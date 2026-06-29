{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.scala.enable = lib.options.mkEnableOption "dev Scala CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.scala.enable {
    cri.packages.pkgs = {
      java.enable = true;
    };

    environment.systemPackages = with pkgs; [
      sbt
    ];

    cri.packages.pkgs.codium.enable = true;
    cri.packages.pkgs.codium.extensions = with pkgs.vscode-extensions; [
      scala-lang.scala
    ];
  };
}
