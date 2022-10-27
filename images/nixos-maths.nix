{ config, pkgs, inputs, system, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Maths";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      lisp.enable = true;
      r.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    libreoffice
  ];

  cri.packages.pythonPackages.nixosMathsCustom = p: with p; [
    beautifulsoup4
    dash
    folium
    graphviz
    imageio
    ipdb
    ipython
    ipywidgets
    jupyter
    jupyterlab
    lxml
    matplotlib
    networkx
    numpy
    openpyxl
    pandas
    pandas-datareader
    pkgs.jupyter-dash
    pkgs.jupyter_contrib_nbextensions
    pkgs.jupyter_latex_envs
    pkgs.nbtranslate
    pkgs.squarify
    pkgs.wikipedia
    plotly
    pygame
    pytorch
    scikit-learn
    scikitimage
    scipy
    seaborn
    seaborn
    termcolor
    xarray
    xlrd
  ];
}
