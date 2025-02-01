{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.python.ssse.enable = lib.options.mkEnableOption "ssse Python CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.python.ssse.enable {
    cri.packages.pythonPackages.ssse = pythonPackages: with pythonPackages; [
      matplotlib
      numpy
      jupyter
      scipy
      scikit-learn
      pillow
      pandas
      pytorch
      torchvision
      torchaudio
      lime
      shap
      seaborn

      # the following are disabled because tensorflow is not compatible with
      # python 3.12
      #tensorflow
      #keras
    ];
  };
}
