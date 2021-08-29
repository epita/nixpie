final: prev: {
  geany = prev.geany.overrideAttrs (old: rec {
    postInstall = ''
      cp ${final.geany-plugin-m68k}/editor/filetypes.asm $out/share/geany/filedefs/filetypes.asm
    '';

    meta = old.meta // {
      # geany-plugin-m68k is only supported on Linux
      platforms = final.lib.platforms.linux;
    };
  });
}
