{ config, pkgs, inputs, system, ... }:

let
  pkgsNlp = import inputs.nixpkgsNlp {
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
  cri.sddm.title = "NixOS NLP";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];

  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [
    dev
    (_: with pkgsNlp.python3Packages; [
      annoy
      beir
      datasets
      fasttext
      gensim
      hnswlib
      ipywidgets
      jupyterlab
      nltk
      pytorch
      scikit-learn
      spacy
      tqdm
      transformers
    ])
  ];
}
