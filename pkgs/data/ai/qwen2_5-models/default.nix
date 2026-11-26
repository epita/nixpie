{ lib, fetchurl, linkFarm }:

# Qwen2.5 models, laid out as Hugging Face model directories in
# $out/lib/iamodels/Qwen/<model>, so they can be loaded offline with
# `AutoModelForCausalLM.from_pretrained("/run/current-system/sw/lib/iamodels/Qwen/<model>")`.
let
  # Files shared by all Qwen2.5 models
  tokenizerFiles = {
    "merges.txt" = "sha256-WZurVAdQiHdLFzP96GXVvXR8vMelR8W8EmEOh04m9eM=";
    "tokenizer.json" = "sha256-wDghF+oynN8JcEETL21zWSS2l5JNb2/DlFcT6WzodTk=";
    "vocab.json" = "sha256-yhDX6fs+0YV13R4neiV5wW0QjjLydDloSvoOELFECRA=";
  };

  models = {
    "Qwen2.5-0.5B" = {
      rev = "060db6499f32faf8b98477b0a26969ef7d8b9987";
      files = tokenizerFiles // {
        "config.json" = "sha256-R53PDFKGM55BrTmSzQiuiKRnxBh1h5NiSOK3yWKDSEs=";
        "generation_config.json" = "sha256-jJcGkjI+PqDpuLCk3KeTiNMSJuQfg8n9YBSAQoDr9ug=";
        "model.safetensors" = "sha256-iMFCVXggzK1Vu1l1a/z8+JHenMYgKBa9NGRFGIoO00I=";
        "tokenizer_config.json" = "sha256-yR78oVzv9unulCTbWKb1nNQSlOVQqGy9B+PB+1ALNPk=";
      };
    };
    "Qwen2.5-0.5B-Instruct" = {
      rev = "7ae557604adf67be50417f59c2c2f167def9a775";
      files = tokenizerFiles // {
        "config.json" = "sha256-GOGK/KzK+t6Y2vE6VAkpJ5BGSeHdTrqCmatxfV2U/0U=";
        "generation_config.json" = "sha256-5ViEeotEAmFvEnN5ewFRBNwmb+S1IAVvyoiCO6j46+Y=";
        "model.safetensors" = "sha256-/fdW+n/L50BNXGDia/8aDIuKofcs7Unn3QIQ/iiPt/4=";
        "tokenizer_config.json" = "sha256-W11PZdCs07LVajW1bTdKNsvByPpc87P+u7+r8i81lYM=";
      };
    };
  };

  modelEntries = model: { rev, files }: lib.mapAttrsToList
    (file: hash: {
      name = "lib/iamodels/Qwen/${model}/${file}";
      path = fetchurl {
        url = "https://huggingface.co/Qwen/${model}/resolve/${rev}/${file}";
        inherit hash;
      };
    })
    files;
in
(linkFarm "qwen2_5-models" (lib.concatLists (lib.mapAttrsToList modelEntries models))).overrideAttrs {
  meta = with lib; {
    description = "Qwen2.5 language models (0.5B base and instruct) for offline use with transformers";
    homepage = "https://huggingface.co/Qwen";
    platforms = platforms.all;
    license = licenses.asl20;
  };
}
