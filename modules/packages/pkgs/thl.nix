{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.thl.enable = lib.options.mkEnableOption "dev THL CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.thl.enable {
    cri.packages.python.thl.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      bison
      flex
      graphviz
    ];
  };
}
