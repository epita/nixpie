{ dumptorrent, fetchFromGitHub, ... }:

dumptorrent.overrideAttrs (old: {
  src = fetchFromGitHub {
    owner = "TheGoblinHero";
    repo = "dumptorrent";
    rev = "bb4b64cb504357dc6ed51bdd27c06062019a268d";
    hash = "sha256-oOOn6tSW796it6r9vzOCsM1H+8UN1ejAHZlrbdShg1U=";
  };
})
