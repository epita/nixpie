{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS GPGPU";

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
  ];

  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ dev ];
}
