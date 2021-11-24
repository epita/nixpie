{ lib
, m68k
, geany
}:

geany.overrideAttrs (old: rec {
  postInstall = (old.postInstall or "") + ''
    cp ${m68k}/share/geany/filedefs/filetypes.asm $out/share/geany/filedefs/filetypes.asm
  '';

  meta = with lib; old.meta // {
    # m68k is only supported on Linux
    platforms = platforms.linux;
  };
})
