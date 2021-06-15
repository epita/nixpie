{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Test.";

  environment.systemPackages = with config.cri.programs; dev;
}
