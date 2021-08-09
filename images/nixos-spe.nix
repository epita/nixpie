{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SPE";

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    devAsm
    devSdl
    devRust
  ];
}
