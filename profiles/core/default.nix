{ pkgs, config, lib, ... }:

with lib;
{
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  console = {
    earlySetup = true;
    keyMap = "us";
  };

  nix = {
    package = pkgs.nixFlakes;
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

    autoOptimiseStore = true;
    gc.automatic = true;
    optimise.automatic = true;

    useSandbox = true;

    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';

    binaryCaches = [ "https://cache.nix.cri.epita.fr" ];
    binaryCachePublicKeys = [ "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo=" ];
  };

  networking = {
    nameservers = [ "10.224.4.2" ];
    timeServers = [
      "ntp.pie.cri.epita.fr"
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
    ];
  };

  security = {
    protectKernelImage = true;
  };

  cri = {
    aria2.enable = true;
    salt.enable = true;
    sshd.enable = true;
    users.enable = true;
    yubikey.enable = true;
  };
  programs.vim.defaultEditor = true;

  environment.systemPackages = with config.cri.programs; core ++ fuse;

  documentation = {
    enable = true;
    man.enable = true;
    info.enable = true;
    doc.enable = true;
    dev.enable = true;
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };
}
