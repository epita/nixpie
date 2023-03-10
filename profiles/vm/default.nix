{ lib, ... }:

{
  netboot = {
    home.enable = true;
    swap.enable = true;
    fallbackNameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  cri.users.checkEpitaUserAllowed = false;

  networking.nameservers = lib.mkForce [ "1.1.1.1" "1.0.0.1" ];

  cri = {
    idle-shutdown.enable = lib.mkForce false;
  };
}
