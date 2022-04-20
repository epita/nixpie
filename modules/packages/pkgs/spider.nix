{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.spider.enable = lib.options.mkEnableOption "dev Spider CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.spider.enable {
    environment.systemPackages = with pkgs; [
      libev
      openssl
    ];
  };
}
