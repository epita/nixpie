{ config, lib, pkgs, ... }:

# Those wrappers are needed to make the packages work with the PIE environment
let
  # Elastic wrappers initiates the ES_HOME environment variable if not set
  # It also copies the elasticsearch store home from the nix store and places it
  # in the ES_HOME directory (keeping only what is needed) in order to make it
  # writable
  elastic-wrapper = pkgs.writeShellScriptBin "elasticsearch" ''
    set -e

    if [ -z "$ES_HOME" ]; then
      export ES_HOME=$HOME/.elasticsearch
    fi

    if [ ! -d "$ES_HOME" ]; then
      mkdir -p $ES_HOME
      cp -r ${pkgs.elasticsearch}/{config,lib,modules,plugins} $ES_HOME/
      chmod +w -R $ES_HOME/
      mkdir -p $ES_HOME/logs
    fi

    exec ${pkgs.elasticsearch}/bin/elasticsearch $@
  '';
  # Neo4j desktop has a problem when creating the jwt addon file by making it
  # read-only. This wrapper makes sure the file is created before starting the
  # application and that it is writable (it makes the errors disappear but
  # breaks authentication, so it needs to be disabled in the GUI after starting)
  neo4j-desktop-wrapper = pkgs.writeShellScriptBin "neo4j-desktop" ''
    set -e

    CONFIG="$HOME/.config/Neo4j Desktop"

    if [ ! -d "$CONFIG" ]; then
      PATCH_DIR="$CONFIG/Application/relate-data/plugin-versions"
      mkdir -p "$PATCH_DIR"
      PATCH_FILE="$PATCH_DIR/neo4j-jwt-addon.json"
      touch "$PATCH_FILE"
      chmod 644 "$PATCH_FILE"
    fi

    exec ${pkgs.neo4j-desktop}/bin/neo4j-desktop $@
  '';
in
{
  options = {
    cri.packages.pkgs.tcinfo.enable = lib.options.mkEnableOption "TCINFO CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.tcinfo.enable {
    cri.packages.pkgs = {
      java.enable = true;
      podman.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # Elastic
      elastic-wrapper
      # MongoDB
      mongodb-ce
      mongodb-tools
      mongosh
      # Neo4j
      neo4j
      neo4j-desktop-wrapper
      kubectl
    ];
  };
}
