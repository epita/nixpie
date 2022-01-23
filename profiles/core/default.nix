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

    autoOptimiseStore = false;
    gc.automatic = false;
    optimise.automatic = false;

    useSandbox = true;

    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';

    binaryCaches = [ "https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr" ];
    binaryCachePublicKeys = [ "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo=" ];
  };

  networking = {
    useDHCP = true;
    dhcpcd = {
      wait = "any"; # make sure we get an IP before marking the service as up
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
    firewall = {
      allowedTCPPortRanges = [
        {
          from = 42000;
          to = 42999;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 42000;
          to = 42999;
        }
      ];
    };
  };

  security = {
    protectKernelImage = true;
  };

  hardware.enableRedistributableFirmware = true;

  cri = {
    aria2.enable = true;
    machine-state.enable = true;
    node-exporter.enable = true;
    nuc-led-setter.enable = true;
    salt.enable = true;
    sshd.enable = true;
    users.enable = true;
    yubikey.enable = true;
  };
  programs.vim = {
    defaultEditor = true;
    package = pkgs.vim_configurable;
  };

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
  environment.pathsToLink = [ "/include" "/lib" ];
  environment.extraOutputsToInstall = [ "out" "lib" "bin" "dev" ];
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";

    NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu = "-I/run/current-system/sw/include";
    NIX_CFLAGS_LINK_x86_64_unknown_linux_gnu = "-L/run/current-system/sw/lib";

    IDEA_JDK = "/run/current-system/sw/lib/openjdk/";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
  };

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

  programs.gnupg = {
    dirmngr.enable = true;
    agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = false;
    };
  };
}
