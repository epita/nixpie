{ lib }:

{
  overlaysToPkgs = import ./overlays-to-pkgs.nix { inherit lib; };
}
