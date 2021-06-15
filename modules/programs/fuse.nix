{ pkgs, ... }:

{
  cri.programs.fuse = with pkgs; [
    fuse
    fuse3
    fuseiso
    sshfs
  ];
}
