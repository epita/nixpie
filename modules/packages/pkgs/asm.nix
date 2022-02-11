{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.asm.enable = lib.options.mkEnableOption "dev ASM CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.asm.enable {
    environment.systemPackages = with pkgs; [
      dosbox
      geany
      m68k
      nasm
    ];
  };
}
