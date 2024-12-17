{ lib, ipxe }:

let
  trustedCerts = [
    (builtins.fetchurl {
      url = "https://ca.ipxe.org/ca.crt";
      sha256 = "sha256:15kwz3liwbdpi8s3v3axaswmp1b3wm3zqps50gmrsiyj4v34fx8d";
    })
    (builtins.fetchurl {
      url = "https://letsencrypt.org/certs/isrgrootx1.pem";
      sha256 = "sha256:1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
    })
    (builtins.fetchurl {
      url = "https://letsencrypt.org/certs/isrg-root-x2.pem";
      sha256 = "sha256:04xh8912nwkghqydbqvvmslpqbcafgxgjh9qnn0z2vgy24g8hgd1";
    })
    (builtins.fetchurl {
      url = "https://letsencrypt.org/certs/lets-encrypt-r3.pem";
      sha256 = "sha256:0clxry49rx6qd3pgbzknpgzywbg3j96zy0227wwjnwivqj7inzhp";
    })
    (builtins.fetchurl {
      url = "https://letsencrypt.org/certs/lets-encrypt-e1.pem";
      sha256 = "sha256:1zwrc6dlk1qig0z23x6x7fib14rrw41ccbf2ds0rw75zccc59xx0";
    })
  ];

  options = {
    "BANNER_TIMEOUT" = 0;
  };

  script = ./forge.ipxe;
in
(ipxe.overrideAttrs (prev: {
  preConfigure = ''
    substituteInPlace src/config/general.h --replace '#define BANNER_TIMEOUT		20' '#define BANNER_TIMEOUT		0'
  '';

  patches = [
    ./wol.patch
  ];

  makeFlags = prev.makeFlags ++ [
    ("CERT=" + builtins.concatStringsSep "," trustedCerts)
    ("TRUST=" + builtins.concatStringsSep "," trustedCerts)
  ];
})).override {
  additionalOptions = [
    "NET_PROTO_IPV6"
    "NET_PROTO_LLDP"
    "DOWNLOAD_PROTO_FILE"
    "CERT_CMD"
    "CONSOLE_CMD"
    "DIGEST_CMD"
    "IPSTAT_CMD"
    "NEIGHBOUR_CMD"
    "NSLOOKUP_CMD"
    "NTP_CMD"
    "PARAM_CMD"
    "PCI_CMD"
    "POWEROFF_CMD"
    "REBOOT_CMD"
    "TIME_CMD"
    "VLAN_CMD"
    "WOL_CMD"
  ];

  embedScript = script;
}
