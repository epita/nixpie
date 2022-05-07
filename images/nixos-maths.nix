{ config, pkgs, inputs, system, ... }:

let
  pkgsMaths = import inputs.nixpkgsMaths {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
in
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
    scikit-learn
    scikitimage
    scipy
    seaborn
    seaborn
    termcolor
    xarray
    xlrd
  ];

  cri.packages.pythonPackages.nixosMathsCustomOverrides = _: with pkgsMaths.python3Packages; [
    annoy
    beir
    datasets
    fasttext
    gensim
    hnswlib
    ipywidgets
    nltk
    pytorch
    scikit-learn
    spacy
    tqdm
    transformers
  ];
}
