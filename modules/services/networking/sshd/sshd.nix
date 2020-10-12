{ config, lib, ... }:

with lib;

{
  options = {
    cri.sshd = {
      enable = mkEnableOption ''
        Whether to enable the OpenSSH secure shell daemon, which allows secure
        remote logins.
      '';
    };
  };

  config = mkIf config.cri.sshd.enable {
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      forwardX11 = true;
      challengeResponseAuthentication = false;
      extraConfig = mkBefore ''
        AllowUsers root
        PermitEmptyPasswords no
      '';
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
