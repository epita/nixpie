{ config, lib, pkgs, ... }:

# Those wrappers are needed to make the packages work with the PIE environment
let
  # OpenSearch wrapper initiates the OS_HOME environment variable if not set
  # It also copies the opensearch store home from the nix store and places it
  # in the OS_HOME directory (keeping only what is needed) in order to make it
  # writable
  opensearch-wrapper = pkgs.writeShellScriptBin "opensearch" ''
    set -e

    if [ -z "$OS_HOME" ]; then
      export OS_HOME=$HOME/.opensearch
    fi

    if [ ! -d "$OS_HOME" ]; then
      mkdir -p $OS_HOME
      cp -r ${pkgs.opensearch}/{config,lib,modules,plugins} $OS_HOME/
      chmod +w -R $OS_HOME/
      mkdir -p $OS_HOME/logs
    fi

    exec ${pkgs.opensearch}/bin/opensearch $@
  '';
  # Neo4j desktop has a problem when creating the jwt addon file by making it
  # read-only. This wrapper makes sure the file is created before starting the
  # application and that it is writable (it makes the errors disappear but
  # breaks authentication, so it needs to be disabled in the GUI after starting)
  #neo4j-desktop-wrapper = pkgs.writeShellScriptBin "neo4j-desktop" ''
  #  set -e

  #  CONFIG="$HOME/.config/Neo4j Desktop"

  #  if [ ! -d "$CONFIG" ]; then
  #    PATCH_DIR="$CONFIG/Application/relate-data/plugin-versions"
  #    mkdir -p "$PATCH_DIR"
  #    PATCH_FILE="$PATCH_DIR/neo4j-jwt-addon.json"
  #    touch "$PATCH_FILE"
  #    chmod 644 "$PATCH_FILE"
  #  fi

  #  exec ${pkgs.neo4j-desktop}/bin/neo4j-desktop $@
  #'';
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
      # OpenSearch
      opensearch-wrapper
      # MongoDB
      mongodb-ce
      mongodb-tools
      mongosh
      # Neo4j
      neo4j
      #neo4j-desktop-wrapper
      kubectl
    ];
  };
}
