{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.devFunctional.enable = lib.options.mkEnableOption "dev CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.devFunctional.enable {
    environment.systemPackages = with pkgs; [
      ghc
      sbcl
    ];
  };
}

