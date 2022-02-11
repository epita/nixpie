{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.fuse.enable = lib.options.mkEnableOption "fuse CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.fuse.enable {
    environment.systemPackages = with pkgs; [
      fuse
      fuse3
      fuseiso
      sshfs
    ];
  };
}
