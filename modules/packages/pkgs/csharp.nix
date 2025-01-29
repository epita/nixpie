{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.csharp.enable = lib.options.mkEnableOption "dev C# CRI package bundle";
    cri.packages.pkgs.csharp.dotnetPackage = lib.options.mkOption {
      type = lib.types.package;
      default = pkgs.dotnet-sdk_7;
      description = "CRI dotnet SDK package";
    };
  };

  config = lib.mkIf config.cri.packages.pkgs.csharp.enable {
    environment.systemPackages = with pkgs; [
      config.cri.packages.pkgs.csharp.dotnetPackage
      jetbrains.rider
    ];

    environment.variables = {
      DOTNET_ROOT = "${config.cri.packages.pkgs.csharp.dotnetPackage}";
    };
  };
}
