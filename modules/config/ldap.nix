{ config, lib, ... }:

with lib;

{
  options = {
    cri.ldap = {
      enable = mkEnableOption "Enable default users";
    };
  };

  config = mkIf config.cri.ldap.enable {
    services.sssd = {
      enable = true;
      config = ''
        [sssd]
        config_file_version = 2
        services = nss, pam, ssh
        domains = LDAP

        [nss]
        override_shell = ${config.users.defaultUserShell}/bin/bash

        [domain/LDAP]
        cache_credentials = true
        enumerate = true

        id_provider = ldap
        auth_provider = ldap

        ldap_uri = ldaps://ldap.pie.cri.epita.fr
        ldap_search_base = dc=cri,dc=epita,dc=fr
        ldap_user_search_base = ou=users,dc=cri,dc=epita,dc=fr?subtree?(objectClass=posixAccount)
        ldap_group_search_base = ou=groups,dc=cri,dc=epita,dc=fr?subtree?(objectClass=posixGroup)
        ldap_id_use_start_tls = true
        ldap_schema = rfc2307bis
        ldap_user_gecos = cn

        entry_cache_timeout = 600
        ldap_network_timeout = 2
      '';
    };

    users = {
      ldap = {
        enable = true;
        base = "dc=cri,dc=epita,dc=fr";
        server = "ldaps://ldap.pie.cri.epita.fr";
        daemon.enable = true;
      };
    };
  };
}
