{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS LAN";

  cri.packages = {
    pkgs = {
      dev.enable = true;
      games.enable = true;
    };
  };

  programs.steam.enable = true;
}
