final: prev: {
  geany = prev.geany.overrideAttrs (old: rec {
    postInstall = ''
      cp ${final.m68k}/share/geany/filedefs/filetypes.asm $out/share/geany/filedefs/filetypes.asm
    '';

    meta = old.meta // {
      # m68k is only supported on Linux
      platforms = final.lib.platforms.linux;
    };
  });
}
