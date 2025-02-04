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
    package = pkgs.nixVersions.stable;

    settings = {
      sandbox = true;
      trusted-users = [ "root" "@wheel" ];
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      substituters = [ "https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr" ];
      trusted-public-keys = [ "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo=" ];
      auto-optimise-store = false;
      auto-allocate-uids = true;
    };

    gc.automatic = false;
    optimise.automatic = false;

    extraOptions = ''
      experimental-features = nix-command flakes auto-allocate-uids
    '';
  };

  networking = {
    useDHCP = true;
    dhcpcd = {
      wait = "any"; # make sure we get an IP before marking the service as up

      # force_hostname is required because nixpkgs#359571 changed the default
      # hostname from localhost to nixos and dhcpcd only changes the hostname if
      # it is localhost.
      extraConfig = ''
        noipv4ll
        env force_hostname=YES
      '';
    };
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

  # TODO: remove me when fixed upstream, sigh.
  systemd.services.dhcpcd = {
    serviceConfig = {
      ProtectHostname = lib.mkForce false;
      SystemCallFilter = lib.mkBefore [ "sethostname" ];
      AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
    };
  };

  security = {
    protectKernelImage = true;
  };
  security.polkit.enable = true;

  hardware.enableRedistributableFirmware = true;

  cri = {
    aria2.enable = true;
    machine-state.enable = true;
    node-exporter.enable = true;
    salt.enable = true;
    sshd.enable = true;
    users.enable = true;
    yubikey.enable = true;
  };
  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.vim_configurable;
  };

  cri.packages = {
    pkgs = {
      core.enable = true;
      fuse.enable = true;
    };

    python = {
      core.enable = true;
    };
  };

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

    CMAKE_INCLUDE_PATH = "/run/current-system/sw/include";
    CMAKE_LIBRARY_PATH = "/run/current-system/sw/lib";

    IDEA_JDK = "/run/current-system/sw/lib/openjdk/";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
  };

  programs.ssh = {
    package = pkgs.openssh_gssapi;
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes

      Host git.forge.epita.fr
        GSSAPIAuthentication yes
      Host git.exam.forge.epita.fr
        GSSAPIAuthentication yes
      Host gitlab.cri.epita.fr
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
      pinentryPackage = pkgs.pinentry-gtk2;
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = false;
    };
  };

  programs.udevil.enable = true;

  services.lldpd.enable = true;

  system.stateVersion = "22.05";
}
