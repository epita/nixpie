{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.js.enable = lib.options.mkEnableOption "dev JS CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.js.enable {
    environment.systemPackages = with pkgs; [
      nodejs-18_x
      yarn
      postman
    ];
  };
}
