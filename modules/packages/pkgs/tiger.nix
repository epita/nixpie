{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.tiger.enable = lib.options.mkEnableOption "dev Tiger CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.tiger.enable {
    environment.systemPackages = with pkgs; [
      autoconf
      automake
      bison
      boost
      flex
      reflex
      gnum4
      gnumake
      #havm
      libtool
      libxslt
      llvmPackages_14.llvm
      #nolimips
      perl
      clang32-alias
      bear
    ];
  };
}
