{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.cri.sshd;
in
{
  options = {
    cri.sshd = {
      enable = mkEnableOption ''
        Whether to enable the OpenSSH secure shell daemon, which allows secure
        remote logins.
      '';
      allowUsers = mkEnableOption ''
        Allow simple users to log in via SSH.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      forwardX11 = true;
      kbdInteractiveAuthentication = false;
      extraConfig = mkBefore
        ((if cfg.allowUsers then ''
          AllowUsers *
          AuthorizedKeysCommand /run/wrappers/bin/sss_ssh_authorizedkeys
          AuthorizedKeysCommandUser nobody
        '' else ''
          AllowUsers root
        '') + ''
          PermitEmptyPasswords no
        '');
    };

    security.wrappers = mkIf cfg.allowUsers {
      sss_ssh_authorizedkeys = {
        source = "${pkgs.sssd}/bin/sss_ssh_authorizedkeys";
        owner = "root";
        group = "root";
      };
    };

    environment.etc = {
      "ssh/ssh_host_rsa_key" = {
        source = ./ssh_host_rsa_key;
        mode = "0600";
      };
      "ssh/ssh_host_rsa_key.pub" = {
        source = ./ssh_host_rsa_key.pub;
        mode = "0600";
      };
      "ssh/ssh_host_ed25519_key" = {
        source = ./ssh_host_ed25519_key;
        mode = "0600";
      };
      "ssh/ssh_host_ed25519_key.pub" = {
        source = ./ssh_host_ed25519_key.pub;
        mode = "0600";
      };
    };
  };
}
