{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.latexExam.enable = lib.options.mkEnableOption "LaTeX Exam CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.latexExam.enable {
    environment.systemPackages = with pkgs; [
      lyx
      texlive.combined.scheme-basic
    ];
  };
}
