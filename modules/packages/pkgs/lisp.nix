{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.lisp.enable = lib.options.mkEnableOption "dev Lisp CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.lisp.enable {
    environment.systemPackages = with pkgs; [
      sbcl
      clisp
      emacs27Packages.slime
    ];
  };
}
