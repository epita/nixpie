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
    };
  };

  config = mkIf config.cri.salt.enable {
    services.salt.minion = {
      enable = true;
      configuration = {
        inherit (config.cri.salt) master;
        id = "nixpie";
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
      wants = [ "network-online.target" ];
      path = [ "/run/current-system/sw" ];

      serviceConfig = {
        Restart = "always";
      };

      preStart = ''
        id="$(${pkgs.nixpie-utils}/bin/get_ip.sh)"
        sed -i '/^id:/d' /etc/salt/minion
        echo -e "\nid: $id" >> /etc/salt/minion
        echo "$id" > /etc/salt/minion_id

        echo "image: ${imageName}" > /etc/salt/grains
        echo "room: $(${pkgs.nixpie-utils}/bin/get_room_name.sh)" >> /etc/salt/grains
        echo "site: $(${pkgs.nixpie-utils}/bin/get_site_name.sh)" >> /etc/salt/grains
      '';
    };
  };
}
