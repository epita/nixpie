{ lib, pkgs }:

let
  shimSigned = builtins.fetchurl {
    url = "http://fr.archive.ubuntu.com/ubuntu/pool/main/s/shim-signed/shim-signed_1.58+15.8-0ubuntu1_amd64.deb";
    sha256 = "sha256:1705r28rmha9p9nc8vzi82dkpkpwqasvzgpjch3c71nqwn05v6xs";
  };

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

    "NET_PROTO_IPV6" = 1;
    "NET_PROTO_LLDP" = 1;

    "DOWNLOAD_PROTO_FILE" = 1;

    "CERT_CMD" = 1;
    "CONSOLE_CMD" = 1;
    "DIGEST_CMD" = 1;
    "IMAGE_TRUST_CMD" = 1;
    "IPSTAT_CMD" = 1;
    "NEIGHBOUR_CMD" = 1;
    "NSLOOKUP_CMD" = 1;
    "NTP_CMD" = 1;
    "PARAM_CMD" = 1;
    "PCI_CMD" = 1;
    "PING_CMD" = 1;
    "POWEROFF_CMD" = 1;
    "REBOOT_CMD" = 1;
    "TIME_CMD" = 1;
    "VLAN_CMD" = 1;
    "WOL_CMD" = 1;
  };

  script = ./forge.ipxe;

  formattedOptions = builtins.concatStringsSep "\n" (
    lib.lists.flatten
      (lib.attrsets.mapAttrsToList
        (opt: value: [
          "#undef ${opt}"
          (if (isNull value) then "" else ("#define ${opt} " + toString value))
        ])
        options
      )
  );
in
(pkgs.ipxe.overrideAttrs (prev: {
  nativeBuildInputs = prev.nativeBuildInputs ++ [
    pkgs.dpkg
  ];

  preConfigure = ''
    cat > src/config/local/general.h <<EOF
    ${formattedOptions}
    EOF
  '';

  patches = [
    ./wol.patch
  ];

  postInstall = ''
    mkdir -p shim
    dpkg-deb --fsys-tarfile "${shimSigned}" | tar --extract --directory="shim"
    cp "shim/usr/lib/shim/shimx64.efi.signed.latest" "$out/shimx64.efi"
    cp "shim/usr/lib/shim/mmx64.efi" "$out/mmx64.efi"
  '';

  makeFlags = prev.makeFlags ++ [
    ("CERT=" + builtins.concatStringsSep "," trustedCerts)
    ("TRUST=" + builtins.concatStringsSep "," trustedCerts)
  ];
})).override { embedScript = script; }
