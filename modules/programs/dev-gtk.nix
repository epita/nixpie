{ pkgs, ... }:

{
  cri.programs.packageBundles.devGtk = with pkgs; [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    gtk3-x11
    harfbuzzFull
    pango
    zlib
  ];
}
