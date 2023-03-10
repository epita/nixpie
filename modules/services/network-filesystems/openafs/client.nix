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

    # The following HUGE mess is to dynamically set AFS cell DB servers IPs from
    # DNS as our machine rooms are now in 2 separate VRF that have to coexist
    # for the time being.
    # How this works : a oneshot service gets each server's IP from DNS and
    # writes the OpenAFS configuration before starting the afsd service.
    # As the config path for afsd is hardcoded to a Nix store path, we also have
    # to replace the preStart script of the service to point it to /etc/afs
    # TODO: remove this when all machine rooms have migrated
    environment.etc.clientCellServDB.enable = false;
    systemd.services.forgeAfsConfig =
      let
        afsCfg = config.services.openafsClient;
      in
      {
        description = "Automatically discover AFS cellDB servers with DNS";
        script = ''
          AFS_CELLDB_CONF="/etc/openafs/CellServDB"
          AFS_HOSTS="afs-0.pie.cri.epita.fr afs-1.pie.cri.epita.fr afs-2.pie.cri.epita.fr"
          echo '>cri.epita.fr' > "$AFS_CELLDB_CONF"
          for h in $AFS_HOSTS; do
              AFS_IP="$(${pkgs.getent}/bin/getent hosts $h | head -n 1 | ${pkgs.gawk}/bin/awk '{ print $1 }')"
              echo "$AFS_IP #$h" >> "$AFS_CELLDB_CONF"
          done

          echo "${afsCfg.mountPoint}:${afsCfg.cache.directory}:${toString afsCfg.cache.blocks}" > /etc/openafs/cacheinfo
        '';

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          type = "oneshot";
        };
      };
    systemd.services.afsd =
      let
        cfg = config.services.openafsClient;
        openafsMod = config.services.openafsClient.packages.module;
        openafsBin = config.services.openafsClient.packages.programs;
        openafsSrv = config.services.openafsServer.package;
      in
      {
        preStart = lib.mkForce ''
          mkdir -p -m 0755 ${cfg.mountPoint}
          mkdir -m 0700 -p ${cfg.cache.directory}
          ${pkgs.kmod}/bin/insmod ${openafsMod}/lib/modules/*/extra/openafs/libafs.ko.xz
          ${openafsBin}/sbin/afsd \
            -mountdir ${cfg.mountPoint} \
            -confdir /etc/openafs \
            ${optionalString (!cfg.cache.diskless) "-cachedir ${cfg.cache.directory}"} \
            -blocks ${toString cfg.cache.blocks} \
            -chunksize ${toString cfg.cache.chunksize} \
            ${optionalString cfg.cache.diskless "-memcache"} \
            -inumcalc ${cfg.inumcalc} \
            ${if cfg.fakestat then "-fakestat-all" else "-fakestat"} \
            ${if cfg.sparse then "-dynroot-sparse" else "-dynroot"} \
            ${optionalString cfg.afsdb "-afsdb"}
          ${openafsBin}/bin/fs setcrypt ${if cfg.crypt then "on" else "off"}
          ${optionalString cfg.startDisconnected "${openafsBin}/bin/fs discon offline"}
        '';
        after = [ "forgeAfsConfig.service" ];
      };

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
