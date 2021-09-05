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
    useDHCP = true;
    dhcpcd = {
      wait = "if-carrier-up"; # make sure we get an IP before marking the service as up
      extraConfig = ''
        noipv4ll
      '';
    };
    nameservers = [ "10.224.21.53" ];
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
    machine-state.enable = true;
    salt.enable = true;
    sshd.enable = true;
    users.enable = true;
    yubikey.enable = true;
  };
  programs.vim.defaultEditor = true;

  cri.programs.packages = with config.cri.programs.packageBundles; [ core fuse ];
  cri.programs.pythonPackages = with config.cri.programs.pythonPackageBundles; [ core ];

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    nixos.enable = true;
  };

  # HACK: this is needed to be able to compile with external libs such as
  # criterion
  environment.pathsToLink = [ "/include" ];
  environment.extraOutputsToInstall = [ "out" "lib" "bin" "dev" ];
  environment.variables.NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu = "-I/run/current-system/sw/include";

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes

      Host exam.pie.cri.epita.fr
        GSSAPIAuthentication yes
      Host git.cri.epita.fr
        GSSAPIAuthentication yes
      Host ssh.cri.epita.fr
        GSSAPIAuthentication yes
        GSSAPIDelegateCredentials yes
    '';
  };
}
