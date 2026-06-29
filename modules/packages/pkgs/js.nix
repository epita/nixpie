{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.js.enable = lib.options.mkEnableOption "dev JS CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.js.enable {
    environment.systemPackages = with pkgs; [
      nodejs_20
      yarn
      #postman
    ];

    cri.packages.pkgs.codium.enable = true;
    cri.packages.pkgs.codium.extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
    ];
  };
}
