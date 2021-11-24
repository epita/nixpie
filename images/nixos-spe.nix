{ config, pkgs, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS SPE";

  cri.programs.packages = with config.cri.programs.packageBundles; [
    dev
    devAsm
    devGtk
    devSdl
    devRust
  ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [
    dev
    (ps: with ps; [
      graphviz
    ])
  ];

  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

  environment.systemPackages = with pkgs; [
    graphviz
  ];
}
