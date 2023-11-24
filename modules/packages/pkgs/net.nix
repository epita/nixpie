{ config, lib, pkgs, ... }:

let
  configGNS3Gui = pkgs.writeText "gns3_gui.conf" ''
    {
        "GraphicsView": {
            "show_grid": true,
            "show_grid_on_new_project": true,
            "snap_to_grid": true,
            "snap_to_grid_on_new_project": true
        },
        "MainWindow": {
            "check_for_update": false,
            "hide_setup_wizard": true,
            "spice_console_command": "remote-viewer spice://%h:%p",
            "telnet_console_command": "alacritty -t %d -e telnet %h %p"
        }
    }
  '';
  configGNS3Server = pkgs.writeText "gns3_server.conf" ''
    [Server]
    path = ${pkgs.gns3-server}/bin/gns3server
    ubridge_path = ubridge
    host = localhost
    port = 3080
    auth = False
    user =
    password =
    auto_start = True
    protocol = http
  '';
  configGNS3Controller = pkgs.writeText "gns3_controller.conf" ''
    {
      "computes": [
          {
              "host": "docker.local",
              "name": "docker.local",
              "port": 3080,
              "protocol": "http",
              "user": null,
              "password": null,
              "compute_id": "d9fc6cf4-f44c-4cbe-b328-f096cdb53bb8"
          }
      ],
      "templates": [
      ],
      "gns3vm": {
          "vmname": "docker.local",
          "when_exit": "stop",
          "headless": false,
          "enable": true,
          "engine": "remote",
          "allocate_vcpus_ram": false,
          "ram": 2048,
          "vcpus": 1,
          "port": 80
      },
      "iou_license": {
          "iourc_content": "",
          "license_check": true
      },
      "appliances_etag": null,
      "version": "${pkgs.gns3-server.version}"
    }
  '';
  custom-gns3-gui = pkgs.writeShellScriptBin "gns3" ''
    USER=$(whoami)

    # Check if the user home exists
    if [ ! -d "/home/$USER" ]; then
      echo "User home directory does not exist"
      exit 1
    fi

    GNS3_VERSION="${pkgs.gns3-gui.version}"
    GNS3_CONFIG_VERSION=$(echo "$GNS3_VERSION" | cut -d'.' -f1-2)
    GNS3_CONFIG_DIR="/home/$USER/.config/GNS3/$GNS3_CONFIG_VERSION"

    # Check if the GNS3 config directory exists
    if [ ! -d "$GNS3_CONFIG_DIR" ]; then
      mkdir -p "$GNS3_CONFIG_DIR"
    fi

    GNS3_CONFIG_SERVER="$GNS3_CONFIG_DIR/gns3_server.conf"
    GNS3_CONFIG_CONTROLLER="$GNS3_CONFIG_DIR/gns3_controller.conf"
    GNS3_CONFIG_GUI="$GNS3_CONFIG_DIR/gns3_gui.conf"

    if [ ! -f "$GNS3_CONFIG_SERVER" ]; then
      echo ".."
      cp --no-preserve=mode,ownership ${configGNS3Server} "$GNS3_CONFIG_SERVER"
    fi

    if [ ! -f "$GNS3_CONFIG_CONTROLLER" ]; then
      echo ".."
      cp --no-preserve=mode,ownership ${configGNS3Controller} "$GNS3_CONFIG_CONTROLLER"
    fi

    if [ ! -f "$GNS3_CONFIG_GUI" ]; then
      echo ".."
      cp --no-preserve=mode,ownership ${configGNS3Gui} "$GNS3_CONFIG_GUI"
    fi

    ${pkgs.gns3-gui}/bin/gns3
  '';
  # It may seem uneccessary but it could be useful in the future
  fix-gns3-config = pkgs.writeShellScriptBin "fix-gns3" ''
    USER=$(whoami)

    # Check if the user home exists
    if [ ! -d "/home/$USER" ]; then
      echo "User home directory does not exist"
      exit 1
    fi

    GNS3_VERSION="${pkgs.gns3-gui.version}"
    GNS3_CONFIG_VERSION=$(echo "$GNS3_VERSION" | cut -d'.' -f1-2)
    GNS3_CONFIG_DIR="/home/$USER/.config/GNS3/$GNS3_CONFIG_VERSION"

    rm -rf "$GNS3_CONFIG_DIR"
  '';
in
{
  options = {
    cri.packages.pkgs.net.enable = lib.options.mkEnableOption "NET CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.net.enable {
    cri.packages.pkgs.docker-vm = {
      enable = lib.mkForce true;
      vmAttributes = {
        environment.systemPackages = with pkgs; [
          gns3-server
          inetutils
          pkgsi686Linux.dynamips
          vpcs
        ];

        security.wrappers.ubridge = {
          source = "${pkgs.ubridge}/bin/ubridge";
          capabilities = "cap_net_admin,cap_net_raw=ep";
          owner = "root";
          group = "root";
          permissions = "u+rx,g+x,o+x";
        };

        systemd.services.gns3-server = {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          path = [
            pkgs.ubridge
            pkgs.pkgsi686Linux.dynamips
            pkgs.vpcs
            pkgs.docker
          ];
          serviceConfig = {
            ExecStart = "${pkgs.gns3-server}/bin/gns3server";
          };
        };

        virtualisation.virtualbox.host.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      custom-gns3-gui
      fix-gns3-config
      gns3-server
      tigervnc
    ];
  };
}
