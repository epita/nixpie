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
