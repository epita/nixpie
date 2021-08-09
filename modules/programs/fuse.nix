{ pkgs, ... }:

{
  cri.programs.packageBundles.fuse = with pkgs; [
    fuse
    fuse3
    fuseiso
    sshfs
  ];
}
