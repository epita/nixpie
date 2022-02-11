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

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    devLisp
  ];

  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [
    dev
    (p: with p; [
      jupyterlab
      numpy
      matplotlib
      scikitimage
      scipy
    ])
    (_: with pkgsMaths.python3Packages; [
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
    ])
  ];
}
