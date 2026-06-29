{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.cpp.enable = lib.options.mkEnableOption "dev C++ CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.cpp.enable {
    environment.systemPackages = with pkgs; [
      httplib
      yaml-cpp
      jetbrains.clion # FIXME: only for exam in 2526, remove me after
    ];

    cri.packages.pkgs.codium.enable = true;
    cri.packages.pkgs.codium.extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      ms-vscode.cmake-tools
      vscodevim.vim
    ];
  };
}
