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
                networking.nameservers = lib.mkVMOverride [ "1.1.1.1" ];
                cri.users.checkEpitaUserAllowed = false;
              }
            ];
          }).config.system.build.vm;
        })
      ];
    };

  hosts = lib.mapAttrs nixosSystem {
    "nixos-docker" = { };
    "nixos-exec" = { };
    "nixos-gpgpu" = { };
    "nixos-image" = { };
    "nixos-lan" = { };
    "nixos-maths" = { };
    "nixos-net" = { };
    "nixos-pie" = { };
    "nixos-spe" = { };
    "nixos-sup" = { };
    "nixos-test" = { };
    "nixos-immersion" = { };
    "nixos-bachelor" = { };
    "nixos-scia" = { };

    "exam-bachelor" = { };
    "exam-inter" = { };
    "exam-pie" = { };
    "exam-prepa" = { };
    "exam-maths" = { };
    "exam-scia" = { };

    "nixos-exec-vm" = { isVM = true; };
    "nixos-pie-vm" = { isVM = true; };
    "nixos-spe-vm" = { isVM = true; };
    "nixos-sup-vm" = { isVM = true; };
    "nixos-test-vm" = { isVM = true; };

    "france-ioi" = { };
  };
in
hosts
