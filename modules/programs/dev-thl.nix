{ pkgs, ... }:

{
  cri.programs.packageBundles.devThl = with pkgs; [
    bison
    flex
    graphviz
  ];

  cri.programs.pythonPackageBundles.devThl = pythonPackages: with pythonPackages; [
    graphviz
  ];
}
