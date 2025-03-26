{ config, lib, ... }:
let
  pkgs.writeShellScriptBin "open-numpy-doc" ''
        #! ${pkgs.runtimeShell}
        ${pkgs.firefox} ${pkgs.numpy-doc}/index.html
      '';
  in
  {
  imports = [
    ../profiles/graphical
    ../profiles/exam

    ./nixos-maths.nix
  ];

  cri.packages = {
    pkgs = {
      latexExam.enable = true;
    };
  };

  cri.sddm.title = lib.mkForce "Exam Maths";

  environment.systemPackages = with pkgs; [
    numpy-doc
    open-numpy-doc
  ];
  }
