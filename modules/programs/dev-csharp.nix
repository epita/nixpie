{ pkgs, ... }:

{
  cri.programs.packageBundles.devCsharp = with pkgs; [
    dotnet-sdk_5
    jetbrains.rider
    mono
    msbuild
  ];
}
