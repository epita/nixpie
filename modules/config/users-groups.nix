{ config, pkgs, lib, ... }:

with lib;
let
  pam_epita = pkgs.writeShellScript "pam_epita" (if config.cri.afs.enable then ''
    export PATH="${pkgs.coreutils}/bin:/run/wrappers/bin:/run/current-system/sw/bin:$PATH"

    if [ "$PAM_TYPE" = "open_session" ]; then
      l1=$(expr substr $PAM_USER 1 1)
      l2=$(expr substr $PAM_USER 1 2)
      afs_u="${config.services.openafsClient.mountPoint}/${config.services.openafsClient.cellName}/user/$l1/$l2/$PAM_USER/u"

      if [ $(id -u) -eq 0 ]; then
        su - "$PAM_USER" -c "[ -e \$HOME/afs ] || ${pkgs.coreutils}/bin/ln -s $afs_u \$HOME/afs"
        su - "$PAM_USER" -c "[ -x \$HOME/afs/.confs/install.sh ] && AFS_DIR=\$HOME/afs \$HOME/afs/.confs/install.sh || true"
      else
        [ -e $HOME/afs ] || ln -s $afs_u $HOME/afs
        [ -x $HOME/afs/.confs/install.sh ] && AFS_DIR=$HOME/afs $HOME/afs/.confs/install.sh || true
      fi
    fi

    if [ "$PAM_TYPE" = "close_session" ]; then
      if [ $(id -u) -ne 0 ]; then
        ${pkgs.procps}/bin/pkill -9 -u "$PAM_USER"
      fi
    fi

    exit 0
  '' else "exit 0");
in
{
  options = {
    cri.users = {
      enable = mkEnableOption "Enable default users";
      createEpitaUser = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to create `epita` user (no password).";
      };
    };

    # As services are submodules, this is a little trick to change the default
    # of an option of those submodules.
    security.pam.services = mkOption {
      type = with types; attrsOf (submodule {
        config = {
          makeHomeDir = mkDefault true;
        };
      });
    };
  };

  config = mkIf config.cri.users.enable {
    security = {
      sudo.wheelNeedsPassword = false;
      # Currently, NixOS does not allow for adding extra stuff to pam. Here are
      # the relevant issues and merge requests:
      # https://github.com/NixOS/nixpkgs/issues/90640
      # https://github.com/NixOS/nixpkgs/issues/90488
      # https://github.com/NixOS/nixpkgs/pull/90490
      pam.services = {
        login.text = ''
          # Authentication management.
          auth  [default=ignore success=1]  pam_succeed_if.so                                         quiet uid <= 1000
          auth  sufficient                  ${pkgs.pam_krb5}/lib/security/pam_krb5.so                 minimum_uid=1000
        '' + (optionalString config.cri.afs.enable ''
          auth  optional                    ${pkgs.pam_afs_session}/lib/security/pam_afs_session.so   program=${config.services.openafsClient.packages.programs}/bin/aklog nopag
        '') + ''
          auth  required                    pam_unix.so                                               try_first_pass nullok
          auth  optional                    pam_permit.so
          auth  required                    pam_env.so                                                conffile=/etc/pam/environment readenv=0

          # Account management.
          account   sufficient  ${pkgs.pam_krb5}/lib/security/pam_krb5.so
          account   required    pam_unix.so
          account   optional    pam_permit.so
          account   required    pam_time.so

          # Password management.
          password  sufficient  ${pkgs.pam_krb5}/lib/security/pam_krb5.so
          password  required    pam_unix.so                           try_first_pass nullok sha512 shadow
          password  optional    pam_permit.so

          # Session management.
          session   [default=ignore success=5]  pam_succeed_if.so                                         uid < 1000
          session   required                    ${pkgs.pam}/lib/security/pam_mkhomedir.so                 silent skel=${config.security.pam.makeHomeDir.skelDirectory} umask=0077
          session   [default=ignore success=3]  pam_succeed_if.so                                         uid <= 1000
          session   required                    ${pkgs.pam_krb5}/lib/security/pam_krb5.so
        '' + (if config.cri.afs.enable then ''
          session   required                    ${pkgs.pam_afs_session}/lib/security/pam_afs_session.so   afs_cells=${config.services.openafsClient.cellName} always_aklog minimum_uid=1000 program=${config.services.openafsClient.packages.programs}/bin/aklog nopag
        '' else ''
          session   [default=ignore]            pam_deny.so
        '') + ''
          session   required                    pam_exec.so                                               ${pam_epita}
          session   optional                    ${pkgs.systemd}/lib/security/pam_systemd.so
          session   required                    pam_unix.so
          session   optional                    pam_permit.so
          session   required                    pam_env.so                                                conffile=/etc/pam/environment readenv=0
          session   required                    pam_loginuid.so
          session   optional                    ${pkgs.pam_subuid}/lib/security/pam_subuid.so
        '';

        i3lock.text = config.security.pam.services.login.text;
        xfce4-screensaver.text = config.security.pam.services.login.text;
        sddm.text = config.security.pam.services.login.text;
        sshd.text = config.security.pam.services.login.text;
      };
    };

    environment.extraInit = ''
      # Needed for afs/.confs/install.sh
      export AFS_DIR=$HOME/afs
    '';

    # Otherwise the configuration refuses to evaluate when cri.afs is disabled
    # because of pam_epita.
    services.openafsClient.packages.programs = mkDefault (getBin pkgs.openafs);

    cri = {
      afs.enable = mkDefault true;
      krb5.enable = mkDefault true;
      ldap.enable = mkDefault true;
    };

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.bashInteractive;

      users = {
        "epita" = mkIf config.cri.users.createEpitaUser {
          hashedPassword = "";
          isNormalUser = true;
          extraGroups = [ "video" "audio" ];
          uid = 1000;
        };

        "root" = {
          hashedPassword = "$6$Fon8AuLkzs7ZjiID$URNhr52P6QzxJN9fCQgWl/IoIAxTZQ9xQKXVy20BWz9ZRqKK22MGG3vLFc485MhgoNghePqq8xw5aTRZJmWqz0";
          initialHashedPassword = "$6$Fon8AuLkzs7ZjiID$URNhr52P6QzxJN9fCQgWl/IoIAxTZQ9xQKXVy20BWz9ZRqKK22MGG3vLFc485MhgoNghePqq8xw5aTRZJmWqz0";

          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMg8mhQrU/IVKy+uglEqkH/+K5kLrQPALk6bWh8GFegA antoined"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAm9U9aupzJB6ArxxnUJkKEzPRnOsYOCRzJc18i+oHt charles"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxxAN/65MNm34RnxXn1uzl7re/cyMGkQimkxdEu1ZOgvBVWUV0iwFedWtmUo3sKpZDW8aVcBdwFd5E+fLGiKK+1BXkLZFj8vPcdNe1EL1L4dfqiAE9dh/wU1+TJbFx2Snxapa6VXpVep3YOUBETT6oC7J48u7o/U5+C9yLvgGRQiDd39hBbITcCKsPkPJTv/VtyonTqZz7k44y3juGATqRSmHEZeVSaFcipEPzH4FroEu1aan8X1mnB578bLy8rEtQ7c8it2L0Pf05IFlNO2gYPAQclzk5rCtKY0U1RdgzdBgt84CZXaJ5wkqmsNC1QhE6+0LgtkwTapIPhO24qBn00CPd/ElOom/hOwEUeUi5y4VUwnFWM3cb9bDK9EneumV4iQsGsIXgp9BFIbywEuS/LdfMsQwBTFoANGMQ1skg4dh+hxt8KdTygjSeh2hK7ZDlyHbnmifUk13SSKnCXHbanvvzuatWgonDtwniPqsay75debSOrEcB+D6fjie9pi7+6N8YP+iC0IZLb1JboN69piwiyIB64HlIE8f3t2cGVrjtKsU/BgtBkIfeiknHezuyqT6sD8uMGZZd2zQkl/Lav9imcrH/H+g48BSvdXWtvlKqqD2K1YvBdLk6n1cFMuHQ8g4CIQXbLds29G55O2Zxo2eyS3IlmVOCDsD8KnhP/Q== nicolas"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmGrJMWaJ5k+D7FfWth1cVepyV/JXHlSKgMoP33YdAK leo"
          ];
        };
      };
    };

    # Kill all user processes when logging out
    services.logind.killUserProcesses = true;
  };
}
