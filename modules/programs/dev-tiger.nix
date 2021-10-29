{ pkgs, ... }:

{
  cri.programs.packageBundles.devTiger = with pkgs; [
    bison-epita
    havm
    nolimips
  ];
}
