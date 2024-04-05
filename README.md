# Nix PIE

Nix PIE is the Nix and NixOS configuration used at EPITA for the school's
computer labs (about 1,000 computers accross the 6 campuses in France).

## NixOS images

Computers at EPITA use network boot (PXE) to run their operating system. We
provide multiple configurations called "images" that contain different sets of
software depending on the course needs or student year. At boot, users are
displayed a menu on which they can choose the configuration they need to use.
The kernel and initrd is then downloaded through HTTPS and the rootfs is
downloaded using the BitTorrent protocol in NixOS Stage 1.

## Repository structure

The repository structure is similar to the official nixpkgs repository.

- `images` contains all the NixOS configurations provided by the flake
- `lib` contains Nix functions used in Nix PIE
- `modules` contains NixOS modules
- `pkgs` contains Nix derivations of software packaged by us
- `profiles` contains shared NixOS configuration between images
- `tests` contains NixOS tests of our configurations

## Testing

To test NixOS configurations, one can start a VM using the following commands:

```sh
# Build the VM
nix build -L .#nixosConfigurations.<NixOS configuration name>.config.system.build.vm

# Start the VM
./result/bin/run-<NixOS configuration name>-vm -smp 4 -m 8192 -vga qxl

# Delete the generated disk image to reset the state of the VM
rm *.qcow2
```
