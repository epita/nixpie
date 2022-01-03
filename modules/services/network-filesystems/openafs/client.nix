{ config, pkgs, lib, inputs, ... }:

with lib;

{
  options = {
    cri.afs = {
      enable = mkEnableOption "Enable default users";
    };
  };

  config = mkIf config.cri.afs.enable {
    cri.krb5.enable = true;

    services.openafsClient = {
      enable = true;
      cellName = "cri.epita.fr";
      cellServDB = [
        { ip = "10.224.21.100"; dnsname = "afs-0.pie.cri.epita.fr"; }
        { ip = "10.224.21.101"; dnsname = "afs-1.pie.cri.epita.fr"; }
        { ip = "10.224.21.102"; dnsname = "afs-2.pie.cri.epita.fr"; }
      ];
      cache = {
        diskless = true;
      };
      fakestat = true;
      packages = {
        module = config.boot.kernelPackages.openafs;
        programs = getBin inputs.pkgset.pkgsUnstable.openafs;
      };
    };
  };
}
