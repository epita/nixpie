{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS NLP";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];

  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [
    dev
    (ps: with ps; [
      nltk
      spacy
      transformers
      jupyterlab
      ipywidgets
      scikit-learn
      tqdm
      fasttext
      gensim
      pytorch
      datasets
    ])
  ];
}
