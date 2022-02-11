{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.gtk.enable = lib.options.mkEnableOption "dev GTK CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.gtk.enable {
    environment.systemPackages = with pkgs; [
      atk
      cairo
      gdk-pixbuf
      glade
      glib
      gtk3
      gtk3-x11
      harfbuzzFull
      pango
      zlib
    ];

    environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  };
}
