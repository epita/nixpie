{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.rust.enable = lib.options.mkEnableOption "dev Rust CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.rust.enable {
    environment.systemPackages = with pkgs; [
      cargo
      rustc
      rustup
    ];
  };
}
