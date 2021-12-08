{ pkgs, ... }:

{
  cri.programs.packageBundles.devThl = with pkgs; [
    graphviz
  ];

  cri.programs.pythonPackageBundles.devThl = pythonPackages: with pythonPackages; [
    graphviz
  ];
}
