{ config, lib, pkgs, ... }:
let
  SecLists = pkgs.fetchFromGitHub {
    owner = "danielmiessler";
    repo = "SecLists";
    rev = "39657bcc05d9dc1637bf30dd0dea0dc70b8ad751";
    sha256 = "yVxb5GaQDuCsyjIV+oZzNUEFoq6gMPeaIeQviwGdAgY=";
  };
in
{
  options = {
    cri.packages.pkgs.nts.enable = lib.options.mkEnableOption "NTS CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.nts.enable {

    cri.users.sessionOpenScript = ''
      ln -s ${SecLists} $HOME/SecLists
    '';

    environment.systemPackages = with pkgs; [
      burpsuite
      wfuzz
      ffuf
      dirbuster
      gobuster
      thc-hydra
      sqlmap
      john
      hashcat
    ];

    virtualisation.oci-containers.containers = {
      dvwa = rec {
        image = "vulnerables/web-dvwa";
        ports = [ "80:80" ];

        imageFile = pkgs.dockerTools.pullImage {
          imageName = image;

          imageDigest = "sha256:dae203fe11646a86937bf04db0079adef295f426da68a92b40e3b181f337daa7";
          sha256 = "sha256-8XV3YQAwtwKkL0MzH1iui7CZMFLMz9uTvkaCvyb6OKU=";

          finalImageName = image;
          finalImageTag = "latest";

          os = "linux";
          arch = "x86_64";
        };
      };
    };
  };
}
