{ salt, python3, ... }:

# FIXME: remove this when https://github.com/NixOS/nixpkgs/pull/430533 reaches
# the release branch. It seems like nixpkgs maintainers are not aiming to
# backport this so it will probably wait until 25.11.

salt.override (old: {
  extraInputs = with python3.pkgs; [
    cryptography
  ];
})
