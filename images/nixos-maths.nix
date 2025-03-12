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
    gnuplot
  ];

  cri.packages.pythonPackages.nixosMathsCustom = p: with p; [
    pkgs.dtale
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
    #pandas-datareader # not working with python>3.12, nixpkgs#310800
    pkgs.jupyter-dash
    #jupyter-contrib-nbextensions
    pkgs.jupyter_latex_envs
    pkgs.nbtranslate
    squarify
    wikipedia
    plotly
    pycryptodome
    pygame
    pytorch
    torchvision
    scikit-learn
    scikitimage
    scipy
    seaborn
    seaborn
    tensorboard
    termcolor
    xarray
    xlrd
    gmpy2
    sounddevice
    soundfile
  ];
}
