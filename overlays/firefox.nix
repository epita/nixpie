final: prev: {
  firefox = prev.firefox.overrideAttrs (old: rec {
    extraPrefs = ''
      pref("network.negotiate-auth.trusted-uris", "cri.epita.fr .cri.epita.fr");
    '';
  });
}
