{ config, pkgs, lib, ... }:

with lib;
let
  pam_epita = pkgs.writeShellScript "pam_epita" ''
    export PATH="${pkgs.coreutils}/bin:/run/wrappers/bin:/run/current-system/sw/bin:$PATH"
    echo "$PATH" >> /tmp/pam_epita

    if [ "$PAM_TYPE" = "auth" ]; then
      login=$(echo "$PAM_USER" | ${pkgs.gnused}/bin/sed 's/\./_/g')
      if [ $(id -u) -eq 0 ]; then
        su - "$PAM_USER" -c "${config.krb5.kerberos}/bin/kinit $login" <&0 || exit 1
      else
        ${config.krb5.kerberos}/bin/kinit $login <&0 || exit 1
      fi
    fi

    if [ "$PAM_TYPE" = "open_session" ]; then
      l1=$(expr substr $PAM_USER 1 1)
      l2=$(expr substr $PAM_USER 1 2)
      afs_u="${config.services.openafsClient.mountPoint}/${config.services.openafsClient.cellName}/user/$l1/$l2/$PAM_USER/u"

      if [ $(id -u) -eq 0 ]; then
        su - "$PAM_USER" -c ${config.services.openafsClient.packages.programs}/bin/aklog
        su - "$PAM_USER" -c "[ -e \$HOME/afs ] || ${pkgs.coreutils}/bin/ln -s $afs_u \$HOME/afs"
        su - "$PAM_USER" -c "[ -x \$HOME/afs/.confs/install.sh ] && AFS_DIR=\$HOME/afs \$HOME/afs/.confs/install.sh"
      else
        ${config.services.openafsClient.packages.programs}/bin/aklog
        [ -e $HOME/afs ] || ln -s $afs_u $HOME/afs
        [ -x $HOME/afs/.confs/install.sh ] && AFS_DIR=$HOME/afs $HOME/afs/.confs/install.sh
      fi
    fi

    if [ "$PAM_TYPE" = "close_session" ]; then
      if [ $(id -u) -eq 0 ]; then
        su - "$PAM_USER" -c ${config.services.openafsClient.packages.programs}/bin/unlog
        su - "$PAM_USER" -c ${config.krb5.kerberos}/bin/kdestroy
      else
        ${config.services.openafsClient.packages.programs}/bin/unlog
        ${config.krb5.kerberos}/bin/kdestroy
      fi
      if [ $(id -u) -ne 0 ]; then
        ${pkgs.procps}/bin/pkill -9 -u "$PAM_USER"
      fi
    fi

    exit 0
  '';
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
  };

  config = mkIf config.cri.users.enable {
    security = {
      sudo.wheelNeedsPassword = false;
      pam = {
        modules.makeHomeDir.enable = true;
      };
      # Currently, NixOS does not allow for adding extra stuff to pam. Here are
      # the relevant issues and merge requests:
      # https://github.com/NixOS/nixpkgs/issues/90640
      # https://github.com/NixOS/nixpkgs/issues/90488
      # https://github.com/NixOS/nixpkgs/pull/90490
      /*pam.services = {
        login.text = ''
          # Account management.
          account   required  ${pkgs.pam_krb5}/lib/security/pam_krb5.so
          account   required  pam_unix.so
          account   optional  pam_permit.so
          account   required  pam_time.so

          # Authentication management.
          auth  [default=ignore success=1]  pam_succeed_if.so   quiet uid <= 1000
          auth  sufficient                  pam_exec.so         quiet expose_authtok ${pam_epita}
          auth  required                    pam_unix.so         try_first_pass nullok
          auth  optional                    pam_permit.so
          auth  required                    pam_env.so          conffile=${config.system.build.pamEnvironment} readenv=0

          # Password management.
          password  sufficient  ${pkgs.pam_krb5}/lib/security/pam_krb5.so
          password  sufficient  pam_unix.so                           try_first_pass nullok sha512 shadow
          password  optional    pam_permit.so

          # Session management.
          session   [default=ignore success=3]  pam_succeed_if.so                           uid < 1000
          session   required                    ${pkgs.pam}/lib/security/pam_mkhomedir.so   silent skel=${config.security.pam.makeHomeDir.skelDirectory} umask=0077
          session   [default=ignore success=1]  pam_succeed_if.so                           uid <= 1000
          session   required                    pam_exec.so                                 ${pam_epita}
          session   optional                    ${pkgs.systemd}/lib/security/pam_systemd.so
          session   required                    pam_unix.so
          session   optional                    pam_permit.so
          session   required                    pam_env.so                                  conffile=${config.system.build.pamEnvironment} readenv=0
        '';
        sddm.text = config.security.pam.services.login.text;
      };*/
    };

    environment.extraInit = ''
      # Needed for afs/.confs/install.sh
      export AFS_DIR=$HOME/afs
    '';

    # Otherwise the configuration refuses to evaluate when cri.afs is disabled
    # because of pam_epita.
    services.openafsClient.packages.programs = mkDefault (getBin pkgs.openafs_1_8);

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
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA4SHJmeor1ZuqU6vY0N0A10TKkI965w5h193/Vv2MGW j4m3s@jormungandr"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhV4xaTiW4x7biob4aaVrZdeyjmC9rDh9VDKey0mVxgGig/tbkd8qcDksvvXjmToJi8Z/qZKIKu7RhAwLD8GZoTjzzO9jGs6fJ9zl6s6qDJk5q3+cununQOQeEvlW3t8Mpk5L9XpaHeP0a309T7ml0nbcuie1IrfoEEsK8kf6pON4MkQGL1Ukc3u3hA5WX/wf6xFsq9Q5lgVPlt+IkO/ohLyuiQeazpBDUuOWlCvJzYx3AyisOB6Uf8cB3xIR5mJt2Ni3DdJry+rnz2k17ouLOmzn1Lr4zDl2/2Xr34JuEt74acHmQm7Zedq5hzkj8pGmXRkVvqidrc8Wpm3ZTcYbSH9K0yLCq82I2V+HpYgSG2IwRDU7t45EEK+m2UVqPrTopCPuogI3q0+MlfDJ3lrUTgmv7eRyBssZco9dvsQhlggFWcCsFJGBSA9A1GXH2EPr6D/43E4nBMRMhu5MbI7e5X+Bymp4rN0fo0GJ+3HCzG24ar9hO5K7pnOAWI1etmNTK2bOW0ttc3ozZUMs6688LUELozXFi+Izvb3pmDzkXva8AT3mFoWhsQ4TLDQlFEiFGwy2Lb6Aqh2WjwG48JolnXq0KjZwEi3qlGm6A5O+D2mXil8uqDiwclDKIolqdqu4YL8PKpBn1CVmwQbk48qkrOIlz4xOcg4pdWpqLptyEOw== mathias@pathfinder"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDW00oEs6dWgG89OQb282lE8ZMzJ1mOvrzuOq3Esc7IboKvAQvGQsdOSOzv7bfkPJTrCW+GRMXFLO+E6W2URg5mta9H0pTlhY062GILFsnZYso/EZTtAIqnXw2EIpv0f+w5xPpZsQ7Xa0XUhkHW9hZJF17ldxQtBcqwbmPeo/D9YYPpdmSdnP6f/GJ9J09HktevQlvhtCtFveGaJ3k0sgNBnbRoMX++tWvqK0ekSjyJhQIKW6ZOdg0Z48of0QrY5Dz/7IUvRWQyin+FxSUDBgQ7lbO5YpO2pfpeNQp0iaZjfVbHtYEXeVEvvn8Eh6XgpNNSsXQeGQM1RBYOMqdV8h3fNUjNHOIZFSqWG6RgGT+dgolMzdY55jGTX/g5lAODSMfnMoiZce0AprJHznFQ4kqGHkDNjGgj935Eczl3qD1go3zn669Jl1NM3C7cwsbtanc+oFy0p7ieElRGGuAL7XcinIdKw9hOFsTOkokrZK8o3oaDrsKCjICR98Ki0a5ffZKdvwVdPy/5qe01gZZXkqb2nqsC2mbTabUO+ttJlE82X8Vt3dQxVo8bBWR7rd1ZxA90t7q2w3sxzsEC4XofxzcZYUe1HL38E2GRT2ALCDehn9yaov646cu2kULuO30UanmGAW2tnob+q5RaQFxeyMaknPWDS4QF8AJkU0jaLNBaFQ== arthur"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMDvCJkRlJMef/V20XSUwxeC7AFIepEUr/5QmJ/KL9f4E+72wEi8tOMOw+J7A3siHcV5zW/QxYCHxn80vC+Lg5LqRl9wZIAbfCSZBCZ8n1wUDjHpFWVARCo2YGeFLYP+WWN6WuDnyjaCZJturUOG5gwzQJ2jS81XPGJj58g3NS7adtMP6/2ifYQNs/DYEFfUX/ClKZ0wdIOfhtwJ9O+wggbVdT4p6op5uXFrVAwWsEjPEw7sR5HDYKrOMlpmle7IWIY3g3F1/oSztA44qH761u+V6RFAOANvXbtlMDu+oc+L1vIHlWm5GJw1TPZB1sJ6AcT9wcIjFVe4SKLDUvY5Ywp+gkxRhtggSk6gNni8KxTeliZjwz3YE+ZVi3C61l0Xt4KIpwJfg7z8lt+BlpuhF6s3ibgE5Ty00VXSfgWRK8or6uMp1Dkj7Kr/Cq1D62uBoeRv9IY1FqboHqxD+Lu+qni3rM0wLyDJJjOvhNUXg5XxmLP+3RP9lwKszk0bniR5BWBxHkGJajzoPlQ1OacZjCqWFSltLP16KhgCrXTA4XUd4omjmQ0BJA8x0xkn5P+IbO6jRwIvDqewpK8+ZeQQNkyo8NBRHOsbPuHE0zfaerGqcTl3yN9KfX3qWRMScJAAqrlTz7raoYbSoZy8tW/SPFigZHf+AEeokIEDDxXSKo+w== sevan@archlab"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9x9hPa7a9DehZFZeofWNwLKl7vCcqakPhIqon3ULqSv0L2wvEfJMMNMVIE2XWK2zjfWVUgK0JJmpUoLMFk5jSfJd7FadcZdNRbsX8OftXMw9bb7KH0vXc4mz2JQ+PKOzOw93ThIkQaziqWQj33i4euAgg3e/HnwbxtK9JscyJfLo75lsxQj80qMwc7fZz7ljPNcYAOHI7Vw7sT5zZ6/a3FDsgKQSc75gj7onBXMCe8ZnlHhVwSZCmZRQoNJFycs7itV/bwTaBzv4KIl6HXO8KX+M+Hg4T04W9doiPFbM52l0TDFk6Un0uMl00FvBAL68wUQU3eK8wn5BoMlLXS8YRnKGvekGuAYHZSiy2ugv21Yp39vpIyJJ5bhgFTG5CAJHfLnmCJuG/hRLv5xxQHVWCnZuvP5CRQLJeoY3Oe6j1CcVT6H/KFWH1RVU9ax7VYg00KzO3rbVhjGjHtEVbu4scIYykhI2y0HM1aIspg4MfZBa21OAP5reJW7CrcbPfGNxBG/11bGL49bBKf58nl8yl4nMz3CvPdZmKNMdxxBpp+2QBQLBhKJ1kiz1b8i/1LP+P5fXgowXB6OuJweO8PlI/HIa+tcYAPFSoH8ll0SqBoUOQ0qv7vj9DqmaL+g/28VgVoM4UwTrmuJH5Yd3ZaGQKgon2zKI9l0ACNXukybodmw== melchior@yubikey"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0pnnKrvi9lrliSm+pf9HNAzs0GYLKiJk5AtSg4hhDq risson@yubikey"
          ];
        };
      };
    };
  };
}
