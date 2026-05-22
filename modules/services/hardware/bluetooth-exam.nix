{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.cri.bluetooth-exam;
in
{
  options = {
    cri.bluetooth-exam = {
      enable = mkEnableOption "Whether to enable conditional bluetooth for exam.";
      endpoint = mkOption {
        type = types.str;
        default = "https://s3.cri.epita.fr/cri-fleet-manager/exam-bluetooth.enabled";
        description = "Endpoint to check bluetooth activation";
      };
    };
  };

  config = mkIf config.cri.bluetooth-exam.enable {
    systemd.services.bluetooth-gate = {
      description = "Exam-mode Bluetooth authorization check";
      before = [ "bluetooth.service" ];
      requiredBy = [ "bluetooth.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeShellScript "bluetooth-gate" ''
          response=$(${pkgs.curl}/bin/curl --fail --max-time 5 \
            ${cfg.endpoint})
          [ "$response" = "true" ]
        ''}";
      };
    };
  };
}
