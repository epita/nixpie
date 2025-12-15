{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.rust.enable = lib.options.mkEnableOption "dev Rust CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.rust.enable {
    environment.systemPackages = with pkgs; [
      cargo
      rustc
      rustfmt # FORGE #66509
      clippy # FORGE #66509
      (writeScriptBin "rust-doc" ''
        echo "Opening Rust documentation..."
        ${xdg-utils}/bin/xdg-open ${rustc.doc}/share/doc/docs/html/index.html >/dev/null 2>/dev/null </dev/null & disown
      '')
    ];
  };
}
