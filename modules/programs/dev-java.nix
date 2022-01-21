{ pkgs, ... }:

{
  cri.programs.packageBundles.devJava = with pkgs; [
    maven
    jetbrains.idea-ultimate
  ];
}
