{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SPE";

  environment.systemPackages = with config.cri.programs; dev ++ devAsm;
}
