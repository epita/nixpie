{ config, ... }:

{
  imports = [
    ./nixos-pie.nix
    ../profiles/vm
  ];
}
