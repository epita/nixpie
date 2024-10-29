{ config, lib, pkgs, ... }:

let
  dotnetDocumentationPdf = pkgs.fetchurl {
    url = "https://learn.microsoft.com/pdf?url=https%3A%2F%2Flearn.microsoft.com%2Ffr-fr%2Fdotnet%2Fapi%2F_splitted%2Fsystem%2Ftoc.json%3Fview%3Dnet-7.0";
    hash = "sha256-xQenB2Vwync8oy1hbYtaNS4iuUcdwD7utBfn/v82Yf0=";
  };
  dotnetDocumentationOpen = pkgs.writeScriptBin "dotnet-documentation" ''
    echo "Opening Dotnet documentation..."
    ${pkgs.xdg-utils}/bin/xdg-open ${dotnetDocumentationPdf} >/dev/null 2>/dev/null </dev/null & disown
  '';
in
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
      mono
      msbuild
      dotnetDocumentationOpen
    ];

    environment.variables = {
      DOTNET_ROOT = "${config.cri.packages.pkgs.csharp.dotnetPackage}";
    };
  };
}
