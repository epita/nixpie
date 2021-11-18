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

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];

  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [
    dev
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
