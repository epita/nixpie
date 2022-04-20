{ pkgs, ... }:

let
  testSuccess = pkgs.writeText "success.c" ''
    #include <ev.h>
    #include <openssl/ssl.h>

    int main() {
      return 0;
    }
  '';
in
{
  machine = { config, pkgs, ... }: {
    cri.packages.pkgs = {
      dev.enable = true;
      spider.enable = true;
    };
  };

  testScript = ''
    start_all()
    machine.succeed("g++ -o success ${testSuccess} -lssl -lcrypto -lev --std=c++17 -Wall -Werror -Wextra")
    machine.succeed("./success")
  '';
}

