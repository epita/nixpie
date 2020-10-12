{ config, lib, ... }:

with lib;
let
  default_realm = "CRI.EPITA.NET";
  kdc = "auth.pie.cri.epita.net";
in
{

  options = {
    cri.krb5 = {
      enable = mkEnableOption "Whether to enable Kerberos authentication.";
    };
  };

  config = mkIf config.cri.krb5.enable {
    krb5 = {
      enable = true;
      libdefaults = {
        inherit default_realm;
      };
      realms."${default_realm}" = {
        inherit kdc;
        admin_server = kdc;
      };
      domain_realm = {
        "cri.epita.net" = default_realm;
        ".cri.epita.net" = default_realm;
      };
    };
  };
}
