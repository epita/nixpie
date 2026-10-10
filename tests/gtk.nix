{ pkgs, ... }:

let
  testSuccess = pkgs.writeText "success.c" ''
    #include <gtk/gtk.h>

    int main(void) {
      return gtk_get_major_version() == 3 ? 0 : 1;
    }
  '';
in
{
  nodes.machine = { config, pkgs, ... }: {
    cri.packages.pkgs.dev.enable = true;
    cri.packages.pkgs.gtk.enable = true;
  };

  testScript = ''
    start_all()
    # zlib, required by gdk-3.0, ships its .pc file in share/pkgconfig
    machine.succeed("pkg-config --exists zlib")
    machine.succeed("pkg-config --cflags --libs gtk+-3.0")
    machine.succeed(
        "gcc $(pkg-config --cflags gtk+-3.0) -Wall -o success ${testSuccess}"
        " $(pkg-config --libs gtk+-3.0)"
    )
    machine.succeed("./success")
  '';
}
