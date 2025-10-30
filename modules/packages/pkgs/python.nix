{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.python.enable = lib.options.mkEnableOption "dev Python CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.python.enable {
    environment.systemPackages = with pkgs; [
      (writeScriptBin "python-doc" ''
        echo "Opening Python documentation..."
        ${xdg-utils}/bin/xdg-open "$(find "${python3.doc}" -maxdepth 5 -name index.html)" >/dev/null 2>/dev/null </dev/null & disown
      '')
    ];
  };
}
