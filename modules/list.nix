{
  krb5 = ./config/krb5.nix;
  ldap = ./config/ldap.nix;
  users = ./config/users-groups.nix;

  nswrappers = ./nswrappers.nix;

  label = ./misc/label.nix;

  programs = ./programs/programs.nix;
  yubikey = ./programs/yubikey.nix;

  machine-state = ./services/admin/machine-state.nix;
  node-exporter = ./services/admin/node-exporter.nix;
  nuc-led-setter = ./services/admin/nuc-led-setter.nix;
  salt = ./services/admin/salt/minion.nix;

  audio = ./services/audio/alsa.nix;
  bluetooth = ./services/hardware/bluetooth.nix;
  afs = ./services/network-filesystems/openafs/client.nix;
  aria2 = ./services/networking/aria2.nix;
  sshd = ./services/networking/sshd/sshd.nix;
  xfce = ./services/x11/desktop-managers/xfce.nix;
  sddm = ./services/x11/display-managers/sddm.nix;
  redshift = ./services/x11/redshift.nix;
  i3 = ./services/x11/window-managers/i3.nix;

  netboot = ./system/boot/netboot.nix;
}
