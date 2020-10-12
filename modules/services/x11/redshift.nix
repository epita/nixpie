{ config, lib, ... }:

with lib;

{
  options = {
    cri.redshift = {
      enable = mkEnableOption "Whether to enable redshift.";
    };
  };

  config = mkIf config.cri.redshift.enable {
    services.redshift = {
      enable = true;
    };

    # Used by redshift to determine sunrise and sunset.
    location = {
      longitude = 48.87951;
      latitude = 2.28513;
    };
  };
}
