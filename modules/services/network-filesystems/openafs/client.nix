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

    boot.kernelPackages = pkgs.linuxPackages.extend (self: super: {
      openafs = super.openafs.overrideAttrs (old: rec {
        version = "1.8.8";
        src = pkgs.fetchurl {
          url = "https://www.openafs.org/dl/openafs/${version}/openafs-${version}-src.tar.bz2";
          sha256 = "sha256-2qjvhqdyf6z83jvJemrRQxKcHCXuNfM0cIDsfp0oTaA=";
        };
        patches = [ ];
      });
    });

    services.openafsClient = {
      enable = true;
      cellName = "cri.epita.fr";
      cellServDB = [
        { ip = "10.224.21.100"; dnsname = "afs-0.pie.cri.epita.fr"; }
        { ip = "10.224.21.101"; dnsname = "afs-1.pie.cri.epita.fr"; }
        { ip = "10.224.21.102"; dnsname = "afs-2.pie.cri.epita.fr"; }
        { ip = "10.224.4.107"; dnsname = "storage-3.pie.cri.epita.fr"; }
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
