{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Test.";

  cri.packages = {
    pkgs = {
      dev.enable = true;
    };
  };
}
