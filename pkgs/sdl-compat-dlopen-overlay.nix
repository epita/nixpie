# `pkgs.SDL` (sdl12-compat) and `pkgs.SDL2` (sdl2-compat) are compatibility
# layers: they implement an old SDL API on top of a newer SDL, which they
# dlopen() by soname and locate through their own RUNPATH.
#
# libasan interposes dlopen(), so the soname ends up being resolved against
# libasan's RUNPATH instead of the compat library's one, and loading fails
# ("sdl12-compat: Failed loading SDL2 library." / "Failed loading SDL3
# library.") as soon as a program is built with -fsanitize=address.
#
# dlopen()ing a full store path instead makes the lookup independent from the
# RUNPATH of whoever calls dlopen().
#
# This overlay is meant to be applied to the SDL package bundles only (see
# modules/packages/pkgs/{sdl,prpa}.nix), applying it globally would rebuild
# every SDL2 consumer, chromium and qtwebengine included.
final: prev:
let
  inherit (prev) lib;

  dlopenFullPath = { package, file, soname, libdir }:
    package.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace ${file} \
          --replace-fail '"${soname}"' '"${libdir}/${soname}"'
      '';
    });

  # sdl2-compat builds against its own sdl3 (tray support disabled): that is
  # the one its RUNPATH points to, and thus the one we must dlopen().
  # buildInputs holds the `dev` output, hence the `.lib` to get back to the
  # output the shared library lives in.
  sdl3 = (lib.findFirst (drv: (drv.pname or null) == "sdl3")
    (throw "sdl2-compat does not have sdl3 in its buildInputs anymore")
    prev.sdl2-compat.buildInputs).lib;
in
{
  sdl2-compat = dlopenFullPath {
    package = prev.sdl2-compat;
    file = "src/sdl2_compat.c";
    soname = "libSDL3.so.0";
    libdir = "${sdl3}/lib";
  };

  SDL_compat = dlopenFullPath {
    package = prev.SDL_compat;
    file = "src/SDL12_compat.c";
    soname = "libSDL2-2.0.so.0";
    libdir = "${lib.getLib final.sdl2-compat}/lib";
  };
}
