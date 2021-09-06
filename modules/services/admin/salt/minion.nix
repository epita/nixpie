{ imageName, config, pkgs, lib, ... }:

with lib;

{
  options = {
    cri.salt = {
      enable = mkEnableOption "Enable salt";
      master = mkOption {
        type = types.str;
        default = "salt.pie.cri.epita.fr";
        description = "Address of the salt master server";
      };
      id = mkOption {
        type = types.str;
        default = imageName;
        description = "id of the minion";
      };
    };
  };

  config = mkIf config.cri.salt.enable {
    services.salt.minion = {
      enable = true;
      configuration = {
        inherit (config.cri.salt) master id;
        startup_states = "highstate";
      };
    };

    environment.etc."salt/minion" = mkForce {
      mode = "0644";
      text = (
        concatStringsSep "\n"
          (mapAttrsToList (n: v: "${n}: ${v}") config.services.salt.minion.configuration)
      );
    };

    systemd.services.salt-minion = {
      after = [ "network-online.target" ];
      path = [ "/run/current-system/sw" ];

      preStart = ''
        while true; do
          ip="$(ip a | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | sed 's#/.*$##')"
          if [ -n "$ip" ] ; then
            break
          fi
          sleep 2
        done

        id="${config.cri.salt.id}-''${ip}"
        sed -i '/^id:/d' /etc/salt/minion
        echo -e "\nid: $id" >> /etc/salt/minion
        echo "$id" > /etc/salt/minion_id
      '';
    };
  };
}
