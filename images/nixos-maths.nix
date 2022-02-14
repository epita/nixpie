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
    };
  };

  cri.packages.pythonPackages.nixosMathsCustom = p: with p; [
    jupyter
    jupyterlab
    numpy
    matplotlib
    scikitimage
    scipy
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
