{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.python.dev.enable = lib.options.mkEnableOption "dev Python CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.python.dev.enable {
    cri.packages.pythonPackages.dev = pythonPackages: with pythonPackages; [
      ipython
      pytest
      pyyaml
    ];
  };
}
