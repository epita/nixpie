{ ciscoPacketTracer8, fetchurl, ... }:

ciscoPacketTracer8.override (old: {
  packetTracerSource = fetchurl {
    url = "https://gitlab.cri.epita.fr/forge/infra/nixpie/-/package_files/19305/download";
    hash = "sha256-bNK4iR35LSyti2/cR0gPwIneCFxPP+leuA1UUKKn9y0=";
  };
})
