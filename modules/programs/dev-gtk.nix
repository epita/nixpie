{ pkgs, ... }:

{
  cri.programs.packageBundles.devGtk = with pkgs; [
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
}
