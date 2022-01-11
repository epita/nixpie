{ pkgs, ... }:

{
  cri.programs.packageBundles.devJava = with pkgs; [
    jdk
    jetbrains.idea-ultimate
  ];
}
