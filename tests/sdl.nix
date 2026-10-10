{ pkgs, ... }:

let
  testSdl = pkgs.writeText "sdl.c" ''
    #include <stdio.h>

    #include <SDL.h>

    int main(void) {
      if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "SDL_Init: %s\n", SDL_GetError());
        return 1;
      }
      SDL_Quit();
      return 0;
    }
  '';
in
{
  nodes.machine = { config, pkgs, ... }: {
    cri.packages.pkgs.dev.enable = true;
    cri.packages.pkgs.sdl.enable = true;
  };

  testScript = ''
    start_all()

    # SDL and SDL2 are compatibility layers dlopen()ing the SDL they are built
    # on top of. libasan interposes dlopen(), which breaks that lookup unless
    # the library is dlopen()ed through its full store path.
    # Leak detection is off: we only care about the libraries being loaded.
    env = (
        "ASAN_OPTIONS=detect_leaks=0 SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy"
    )

    for pkg in ["sdl", "sdl2"]:
        machine.succeed(
            f"gcc $(pkg-config --cflags {pkg}) -Wall -o {pkg}-test ${testSdl}"
            f" $(pkg-config --libs {pkg})"
        )
        machine.succeed(f"{env} ./{pkg}-test")

        machine.succeed(
            f"gcc -fsanitize=address $(pkg-config --cflags {pkg})"
            f" -Wall -o {pkg}-test-asan ${testSdl} $(pkg-config --libs {pkg})"
        )
        machine.succeed(f"{env} ./{pkg}-test-asan")
  '';
}
