{ pkgs, ... }:

let
  testSuccess = pkgs.writeText "success.c" ''
    #include <criterion/criterion.h>

    Test(simple, test) {
      cr_assert(1, "success");
    }
  '';
  testFail = pkgs.writeText "fail.c" ''
    #include <criterion/criterion.h>

    Test(simple, test) {
      cr_assert(0, "fail");
    }
  '';
in
{
  machine = { config, pkgs, ... }: {
    cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];
  };

  testScript = ''
    start_all()
    machine.succeed("gcc -o success ${testSuccess} -lcriterion --std=c99 -Wall -Werror -Wextra -pedantic")
    machine.succeed("./success")
    machine.succeed("gcc -o fail ${testFail} -lcriterion --std=c99 -Wall -Werror -Wextra -pedantic")
    machine.fail("./fail")
  '';
}
