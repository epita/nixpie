{ config, lib, pkgs, ... }:
{
  options = {
    cri.packages.pkgs.nts.enable = lib.options.mkEnableOption "NTS CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.nts.enable {

    cri.packages.pythonPackages.nts = p: with p; [
      ipython
      jupyter
      matplotlib
      numpy
      openai
      pandas
      requests
      tiktoken
      torch
      transformers
    ];

    # Bundle the AI models so that students do not download them from
    # Hugging Face (rate limits, homes in tmpfs).
    # They are available in /run/current-system/sw/lib/iamodels.
    environment.systemPackages = [ pkgs.qwen2_5-models ];
    environment.pathsToLink = [ "/lib/iamodels" ];

    # tiktoken encodings, used by tiktoken.get_encoding() without network
    environment.sessionVariables.TIKTOKEN_CACHE_DIR = "${pkgs.tiktoken-encodings}/share/tiktoken";
  };
}
