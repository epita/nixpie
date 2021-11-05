{ config, pkgs, lib, ... }:

let
  submission = pkgs.writeShellScriptBin "submission" ''
    #!/bin/sh

    if [ ! -f ~/.allow_submission ]; then
      echo -e "[\033[31mERROR\033[0m] Submission script not allowed"
      exit 1
    fi

    cd "$HOME/submission"

    echo "* Trying to submit"

    git checkout master
    git add --all
    git commit -m "Submission" --allow-empty
    git push origin master
  '';
in
{
  imports = [
    ../profiles/exam

    ./nixos-sup.nix
    ./nixos-spe.nix
  ];

  cri.sddm.title = lib.mkForce "Exam Prepa";
  cri.xfce.enable = lib.mkForce false;

  environment.systemPackages = [ submission ];
}
