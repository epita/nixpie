{ pkgs, ... }:

{
  cri.programs.packageBundles.devJava = with pkgs; [
    jetbrains.idea-ultimate
    maven
  ];
}
