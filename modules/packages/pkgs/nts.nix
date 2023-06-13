{ config, lib, pkgs, ... }:
let
  SecLists = pkgs.fetchFromGitHub {
    owner = "danielmiessler";
    repo = "SecLists";
    rev = "39657bcc05d9dc1637bf30dd0dea0dc70b8ad751";
    sha256 = "yVxb5GaQDuCsyjIV+oZzNUEFoq6gMPeaIeQviwGdAgY=";
  };
  firefoxBurpProfile = "$HOME/.firefox-burps-profile";
  prefsJs = pkgs.writeText "pref.js" ''
    user_pref("network.proxy.allow_hijacking_localhost", true);
    user_pref("network.proxy.backup.ssl", "");
    user_pref("network.proxy.backup.ssl_port", 0);
    user_pref("network.proxy.http", "127.0.0.1");
    user_pref("network.proxy.http_port", 8080);
    user_pref("network.proxy.share_proxy_settings", true);
    user_pref("network.proxy.ssl", "127.0.0.1");
    user_pref("network.proxy.ssl_port", 8080);
    user_pref("network.proxy.type", 1);
  '';
  firefox-burp = pkgs.writeScriptBin "firefox-burp" ''
    ${pkgs.firefox}/bin/firefox --profile "${firefoxBurpProfile}"
  '';
  nts-start = pkgs.writeScriptBin "nts-start" ''
    ${firefox-burp}/bin/firefox-burp &
    ${pkgs.firefox}/bin/firefox &
    ${pkgs.burpsuite}/bin/burpsuite &
  '';
in
{
  options = {
    cri.packages.pkgs.nts.enable = lib.options.mkEnableOption "NTS CRI package bundle";
  };

  config = lib.mkIf config.cri.packages.pkgs.nts.enable {

    cri.users.sessionOpenScript = ''
      ln -s ${SecLists} "$HOME/SecLists" || true
      mkdir -p ${firefoxBurpProfile}
      if [ ! -f "${firefoxBurpProfile}/prefs.js" ]; then
        cp ${prefsJs} "${firefoxBurpProfile}/prefs.js"
      fi
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

      firefox-burp
      nts-start
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
