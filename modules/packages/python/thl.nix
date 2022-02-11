{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.python.thl.enable = lib.options.mkEnableOption "dev THL Python CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.python.thl.enable {
    cri.packages.pythonPackages.thl = pythonPackages: with pythonPackages; [
      graphviz
    ];
  };
}
