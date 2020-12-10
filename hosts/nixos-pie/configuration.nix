{ nixpie, ... }:

{
  imports = [
    nixpie.nixosModules.profiles.graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Test.";
}
