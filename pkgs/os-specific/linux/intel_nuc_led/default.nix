{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation {
  pname = "intel_nuc_led";
  version = "unstable";

  passthru.moduleName = "intel_nuc_led";

  src = fetchFromGitHub {
    owner = "milesp20";
    repo = "intel_nuc_led";
    rev = "6a3850eadff554053ca7d95e830a624b28c53670";
    sha256 = "sha256-XMhBKu3H09SiavrJYzEccFW8VaKigG+xDsdGdNOkJZw=";
  };

  patches = [ ./linux-5.6.patch ];

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [
    "KVERSION=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "default"
  ];

  installPhase = ''
    install -D nuc_led.ko $out/lib/modules/${kernel.modDirVersion}/misc/nuc_led.ko
  '';

  meta = with lib; {
    maintainers = [ maintainers.risson ];
    license = licenses.gpl3;
    platforms = [ "i686-linux" "x86_64-linux" ];
    description = "Intel NUC7i[x]BN and NUC6CAY LED Control for Linux";
    homepage = "https://github.com/milesp20/intel_nuc_led";
  };
}
