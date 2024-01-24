{ config, lib, pkgs, ... }:

{
  options = {
    cri.packages.pkgs.libvirt.enable = lib.options.mkEnableOption "libvirt Forge package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.libvirt.enable {
    virtualisation.libvirtd = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      virt-manager
    ];

    systemd.services.libvirtd-config.script = lib.mkAfter ''
      mkdir -p /var/lib/libvirt/qemu/networks/autostart
      ln -s /var/lib/libvirt/qemu/networks/default.xml /var/lib/libvirt/qemu/networks/autostart/
    '';
  };
}
