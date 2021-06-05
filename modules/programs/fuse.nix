{ pkgs, ... }:

{
  cri.packages.fuse = with pkgs; [
    fuse
    fuse3
    fuseiso
    sshfs
  ];
}
