{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.sdl.enable = lib.options.mkEnableOption "dev SDL CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.sdl.enable {
    environment.systemPackages = with pkgs; [
      # v1
      SDL
      SDL_Pango
      SDL_gfx
      SDL_image
      SDL_mixer
      SDL_net
      SDL_ttf

      # v2
      SDL2
      SDL2_image
      SDL2_mixer
      SDL2_net
      SDL2_ttf

      libGLU

      alsa-lib
      libpulseaudio
    ];
  };
}
