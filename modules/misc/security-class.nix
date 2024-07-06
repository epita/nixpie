{ lib, ... }:

{
  options = {
    system.nixos.securityClass = lib.mkOption {
      type = lib.types.str;
      default = "misc";
    };
  };
}
