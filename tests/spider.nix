{ pkgs, ... }:

let
  testSuccess = pkgs.writeText "success.c" ''
    #include <ev.h>
    #include <openssl/ssl.h>
    #include <boost/iterator/iterator_facade.hpp>

    int main() {
      return 0;
    }
  '';
in
{
  machine = { config, pkgs, ... }: {
    cri.programs.packages = with config.cri.programs.packageBundles; [ dev devSpider ];
  };

  testScript = ''
    start_all()
    machine.succeed("g++ -o success ${testSuccess} -lssl -lcrypto -lev --std=c++17 -Wall -Werror -Wextra")
    machine.succeed("./success")
  '';
}

