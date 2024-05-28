{ config, lib, ... }:

with lib;
{

  options = {
    cri.krb5 = {
      enable = mkEnableOption "Whether to enable Kerberos authentication.";
    };
  };

  config = mkIf config.cri.krb5.enable {
    security.krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          default_realm = "CRI.EPITA.FR";
          dns_fallback = true;
          dns_canonicalize_hostname = false;
          rnds = false;
          forwardable = true;
        };

        realms = {
          "CRI.EPITA.FR" = {
            admin_server = "kerberos.pie.cri.epita.fr";
          };
        };
      };
    };
  };
}
