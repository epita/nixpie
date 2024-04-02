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

  makeLocal = { ... } @ attr: builtins.listToAttrs (map (x: { name = "${x}-local"; value = (builtins.getAttr x attr) // { isLocal = true; }; }) (builtins.attrNames attr));

  nixosSystem = imageName: { isVM ? false, isLocal ? false, extraModules ? [ ] } @ args:
    let
      _imageName = if isVM then lib.removeSuffix "-vm" imageName else if isLocal then lib.removeSuffix "-local" imageName else imageName;

      specialArgs = import ./special-args.nix inputs imageName;

      modules =
        let
          inherit (import ./modules.nix inputs imageName) core global flakeModules;
          local = import "${toString ./.}/${_imageName}.nix";
        in
        flakeModules ++ [ core global local ] ++ (lib.optional isVM ../profiles/vm) ++ (lib.optional isLocal ../profiles/local) ++ extraModules;
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
                cri.sm-inventory-agent.enable = lib.mkForce false;
              }
            ];
          }).config.system.build.vm;
        })
      ];
    };

  allHosts = {
    "nixos-docker" = { };
    "nixos-exec" = { };
    #"nixos-gpgpu" = { }; # disabled because cuda on NixOS is broken
    "nixos-image" = { };
    "nixos-lan" = { };
    "nixos-maths" = { };
    "nixos-net" = { };
    "nixos-nts" = { };
    "nixos-pie" = { };
    "nixos-prepa" = { };
    "nixos-test" = { };
    "nixos-immersion" = { };
    "nixos-ssse" = { };
    "nixos-majeures" = { };
    "nixos-summer-program" = { };
    "nixos-cnix-tty" = { };

    "exam-pie" = { };
    "exam-prepa" = { };
    "exam-maths" = { };
    "exam-majeures" = { };

    "nixos-exec-vm" = { isVM = true; };
    "nixos-pie-vm" = { isVM = true; };
    "nixos-prepa-vm" = { isVM = true; };
    "nixos-test-vm" = { isVM = true; };

    "france-ioi" = { };
    "exam-france-ioi" = { };
  };

  localHosts = makeLocal allHosts;

  hosts = lib.mapAttrs nixosSystem (allHosts // localHosts);
in
hosts
