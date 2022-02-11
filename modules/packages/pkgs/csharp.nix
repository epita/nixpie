{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.csharp.enable = lib.options.mkEnableOption "dev C# CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.csharp.enable {
    environment.systemPackages = with pkgs; [
      dotnet-sdk_5
      jetbrains.rider
      mono
      msbuild
    ];
  };
}
