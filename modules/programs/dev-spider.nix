{ pkgs, ... }:

{
  cri.programs.packageBundles.devSpider = with pkgs; [
    boost
    libev
    openssl
  ];
}
