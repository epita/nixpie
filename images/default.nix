{ lib
, nixpkgs
, nixpkgsMaster
, nixpkgsUnstable
, pkgset
, self
, system
, ...
} @ inputs:
let

  nixosSystem = imageName: { isVM ? false, extraModules ? [ ] } @ args:
    let
      _imageName = if isVM then lib.removeSuffix "-vm" imageName else imageName;

      specialArgs = import ./special-args.nix inputs imageName;

      modules =
        let
          inherit (import ./modules.nix inputs imageName) core global flakeModules;
          local = import "${toString ./.}/${_imageName}.nix";
        in
        flakeModules ++ [ core global local ] ++ (lib.optional isVM ../profiles/vm) ++ extraModules;
    in
    lib.nixosSystem {
      inherit system specialArgs;


      modules = modules ++ [
        ({ lib, modulesPath, ... }: {
          system.build.vm = (import "${modulesPath}/../lib/eval-config.nix" {
            inherit system specialArgs;
            modules = modules ++ [
              "${modulesPath}/virtualisation/qemu-vm.nix"
              {
                netboot.enable = lib.mkVMOverride false;
              }
            ];
          }).config.system.build.vm;
        })
      ];
    };

  hosts = lib.mapAttrs nixosSystem {
    "nixos-exec" = { };
    "nixos-gpgpu" = { };
    "nixos-lan" = { };
    "nixos-maths" = { };
    "nixos-pie" = { };
    "nixos-spe" = { };
    "nixos-sup" = { };
    "nixos-test" = { };

    "exam-pie" = { };
    "exam-prepa" = { };

    "nixos-exec-vm" = { isVM = true; };
    "nixos-pie-vm" = { isVM = true; };
    "nixos-spe-vm" = { isVM = true; };
    "nixos-sup-vm" = { isVM = true; };
    "nixos-test-vm" = { isVM = true; };

    "france-ioi" = { };
  };
in
hosts
