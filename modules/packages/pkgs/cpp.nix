{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.cpp.enable = lib.options.mkEnableOption "dev C++ CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.cpp.enable {
    environment.systemPackages = with pkgs; [
      httplib
      libyamlcpp
    ];
  };
}
