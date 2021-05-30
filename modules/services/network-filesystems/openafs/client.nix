{ config, pkgs, lib, ... }:

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
        { ip = "10.224.4.107"; dnsname = "storage-3.pie.cri.epita.net"; }
      ];
      cache = {
        diskless = true;
      };
      fakestat = true;
      packages = {
        module = config.boot.kernelPackages.openafs_1_8;
        programs = getBin pkgs.openafs_1_8;
      };
    };
  };
}
