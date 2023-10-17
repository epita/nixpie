{ config, pkgs, lib, ... }:

let
  submit = pkgs.writeShellScriptBin "submit" ''
    #!${pkgs.bash}/bin/bash

    function usage() {
      echo "USAGE: submit EXERCICE_SLUG"
      echo "possible exercices: empty, content, hello-world"
    }

    if [ "$#" -ne 1 ]; then
      echo -e "[\033[31mERROR\033[0m] Invalid argument"
      usage
      exit 1
    fi

    case "$1" in
    empty | content | hello-world)
      echo "Submitting exercise: $1"
      ;;
    *)
      echo "invalid exercise"
      usage
      exit 1
      ;;
    esac

    git checkout master
    git add --all
    git commit -m "Submission" --allow-empty
    git tag -a "$1-$(date +%s)" -m "submission"
    git push origin master --follow-tags
  '';
in
{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = false;

  cri = {
    aria2.enable = lib.mkForce false;
    machine-state.enable = lib.mkForce false;
    node-exporter.enable = lib.mkForce false;
    idle-shutdown.enable = lib.mkForce false;
    afs.enable = false;
    sddm.title = "NixOS JPO";
    users.checkEpitaUserAllowed = false;
  };

  networking.hostName = "FIXME";
  networking.wireless = {
    userControlled.enable = true;
    enable = true;
    environmentFile = "/var/secrets/wireless.env";
    networks.IONIS = {
      authProtocols = [ "WPA-EAP" ];
      auth = ''
        eap=PEAP
        identity="@WIFI_USER@"
        password="@WIFI_PASS@"
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    git
    gnome.gedit
    python3
    submit
    wpa_supplicant_gui
    arandr
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" "rtsx_pci_sdmmc" "nvme" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };
  swapDevices = [
    { device = "/dev/disk/by-label/nixos-swap"; }
  ];

  services.xserver.windowManager.i3 = {
    extraSessionCommands = lib.mkAfter ''
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --off
      ${pkgs.git}/bin/git config --global user.name "$(id -u -n)"
      ${pkgs.git}/bin/git config --global user.email "$(id -u -n)@forge.epita.fr"
    '';
  };
}
