{ pkgs, ... }:

{
  cri.programs.devCsharp = with pkgs; [
    dotnet-sdk_5
    jetbrains.rider
    mono
    msbuild
  ];
}
