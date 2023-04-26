{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.net.enable = lib.options.mkEnableOption "NET CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.net.enable {
    environment.systemPackages = with pkgs; [
      gns3-gui
      gns3-server
      inetutils
      pkgsi686Linux.dynamips
      vpcs
    ];

    virtualisation.virtualbox.host.enable = true;

    security.wrappers.ubridge = {
      source = "${pkgs.ubridge}/bin/ubridge";
      capabilities = "cap_net_admin,cap_net_raw=ep";
      owner = "root";
      group = "root";
      permissions = "u+rx,g+x,o+x";
    };
  };
}
