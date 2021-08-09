{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Test.";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];
}
