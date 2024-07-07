{ lib, config, pkgs, ... }:

{
  options = {
    cri.boot.splash = {
      enable = lib.mkEnableOption "Enable boot splash screen";
    };
  };

  config = lib.mkIf config.cri.boot.splash.enable {
    boot.plymouth = {
      enable = true;
      theme = "forge";
      themePackages = [
        pkgs.plymouth-forge-theme
      ];
    };

    # Override plymouthd for a dummy file, so that it doesn't get started in preLVMCommands
    # This is needed because starting plymouthd before the torrent ends breaks the network
    # in the initrd for some reason.
    # As such, we only start it once aria2 is done with downloading.
    boot.initrd.preLVMCommands = lib.mkBefore ''
      mv /bin/plymouthd /bin/plymouthd_real
      echo '#!/bin/sh' > /bin/plymouthd
      chmod +x /bin/plymouthd
    '';

    boot.initrd.extraFiles = {
      "/plymouth-start.sh".source = pkgs.writeShellScript "plymouth-start.sh" ''
        plymouthd_real --mode=boot --pid-file=/run/plymouth/pid --attach-to-session
        plymouth show-splash
        { sleep 10; plymouth display-message --text="Press Escape to show boot logs" ; } &
      '';
    };
  };
}
