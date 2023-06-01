{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.nts.enable = lib.options.mkEnableOption "NTS CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.nts.enable {
    environment.systemPackages = with pkgs; [
      burpsuite
      wfuzz
      # ffuzz
      # dirbuster
      gobuster
      thc-hydra
      sqlmap
      john
      hashcat
    ];
  };
}
