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
          auth  optional                    ${pkgs.pam_afs_session}/lib/security/pam_afs_session.so   program=${config.services.openafsClient.packages.programs}/bin/aklog
          auth  required                    pam_unix.so                                               try_first_pass nullok
          auth  optional                    pam_permit.so
          auth  required                    pam_env.so                                                conffile=${config.system.build.pamEnvironment} readenv=0

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
          session   required                    ${pkgs.pam_afs_session}/lib/security/pam_afs_session.so   afs_cells=cri.epita.fr always_aklog minimum_uid=1000 program=${config.services.openafsClient.packages.programs}/bin/aklog
          session   required                    pam_exec.so                                               ${pam_epita}
          session   optional                    ${pkgs.systemd}/lib/security/pam_systemd.so
          session   required                    pam_unix.so
          session   optional                    pam_permit.so
          session   required                    pam_env.so                                                conffile=${config.system.build.pamEnvironment} readenv=0
        '';

        i3lock.text = config.security.pam.services.login.text;
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
          hashedPassword = "$6$tpp1raK3wZhH$8O.KfGHijOYyJPNcRMhy6q6WtDfut9oMu/v9mUj3tWQfKfYOkv87bzdYKz/2OsHZza3vsbx8hXTbPmtIBYmK.1";

          openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRjWonANQ/xE+bAU6e0Wd2s97ONLuHP9EPxdeQTf48NdMOBq/Zyuej8xRd91tHjsF230wMkQemDkSWgEmM9w99yXVt3IOtRizchAQLKEq+3R0eU6gES/gFZ9VL6bNei0jvWAhqNDn7bb/k5FmS+Joy4nsINxmHPBzhJFlcGfENrpUl/lPfWOoldkEjNZ8Wzaxx+OIcvoxsITlOVLu5zD/sRhDS82R6Dr4xPnJxVUxHfmB+ypRTfjA/gBW3JLFxe/GvgpfNpX20OsZPlzyLedW/Km3v3kUFDM5ygAArIAi/LCGohYLF+qkofrj3IM+mxI98ysa8g6SA5jKpC/SA0mZbadUfQJRrFYJp0cJcweMqshqwYG1F4uxm0dv2XTMaoSTn+RixKhIYi9TZK6FWzSZf96tb+n17ZybSv+y+KB1Qa5eJxxaGdFbwO2XAXLtTlhSfPW96AKOSD+d+0N+lJLPOj8HpQiv7+Qq2tUmtNIbelfg7Fzeei9WcsAJvXiHlj5ZOKREsZwe8Z+7gy1XtS57yaq2ogx27vpEYpPqjpX75LSvwxuDBr/5/gEZfDhucLo0LNT9w3mxu6LZCuQB1hNER2IoIADEvizEHyEBguqPYWo7542WJn87nXpy9wwYo7R5Pmv0hVOXCl9NcuEIcZDcvB31cjLLOEf2C546umjMVvw== Marin Hannache (Mareo)"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9x9hPa7a9DehZFZeofWNwLKl7vCcqakPhIqon3ULqSv0L2wvEfJMMNMVIE2XWK2zjfWVUgK0JJmpUoLMFk5jSfJd7FadcZdNRbsX8OftXMw9bb7KH0vXc4mz2JQ+PKOzOw93ThIkQaziqWQj33i4euAgg3e/HnwbxtK9JscyJfLo75lsxQj80qMwc7fZz7ljPNcYAOHI7Vw7sT5zZ6/a3FDsgKQSc75gj7onBXMCe8ZnlHhVwSZCmZRQoNJFycs7itV/bwTaBzv4KIl6HXO8KX+M+Hg4T04W9doiPFbM52l0TDFk6Un0uMl00FvBAL68wUQU3eK8wn5BoMlLXS8YRnKGvekGuAYHZSiy2ugv21Yp39vpIyJJ5bhgFTG5CAJHfLnmCJuG/hRLv5xxQHVWCnZuvP5CRQLJeoY3Oe6j1CcVT6H/KFWH1RVU9ax7VYg00KzO3rbVhjGjHtEVbu4scIYykhI2y0HM1aIspg4MfZBa21OAP5reJW7CrcbPfGNxBG/11bGL49bBKf58nl8yl4nMz3CvPdZmKNMdxxBpp+2QBQLBhKJ1kiz1b8i/1LP+P5fXgowXB6OuJweO8PlI/HIa+tcYAPFSoH8ll0SqBoUOQ0qv7vj9DqmaL+g/28VgVoM4UwTrmuJH5Yd3ZaGQKgon2zKI9l0ACNXukybodmw== melchior@yubikey"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0pnnKrvi9lrliSm+pf9HNAzs0GYLKiJk5AtSg4hhDq risson@yubikey"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvso1QjsOLrWyVoqkqQjre0TD6LE9djVWTCvkUDjgoe rootmout"
          ];
        };
      };
    };

    # Kill all user processes when logging out
    services.logind.killUserProcesses = true;
  };
}
