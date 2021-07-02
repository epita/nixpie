{
  netboot = {
    enable = true;
    bootcache.enable = false;
  };

  cri = {
    afs.enable = false;
    krb5.enable = false;
    ldap.enable = false;
    users.createEpitaUser = false;
  };
}
