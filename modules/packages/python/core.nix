{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.python.core.enable = lib.options.mkEnableOption "core Python CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.python.core.enable {
    cri.packages.pythonPackages.core = pythonPackages: with pythonPackages; [
      pip
      virtualenv
    ];
  };
}
