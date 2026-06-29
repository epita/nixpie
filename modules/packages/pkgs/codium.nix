{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.codium.enable = lib.options.mkEnableOption "enable VS Codium";

    cri.packages.pkgs.codium.extensions = lib.options.mkOption {
      default = [ ];
      type = with lib.types; listOf package;
      description = "List of Codium extensions to install.";
    };
  };

  config = lib.mkIf config.cri.packages.pkgs.codium.enable {
    environment.systemPackages = with pkgs; [
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = config.cri.packages.pkgs.codium.extensions;
      })
    ];
  };
}
