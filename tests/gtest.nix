{ pkgs, ... }:

let
  testSuccess = pkgs.writeText "success.cc" ''
    #include <gtest/gtest.h>

    TEST (PassingTest, Passing)
    {
        EXPECT_EQ(1, 1);
    }

    int main(int argc, char **argv)
    {
        ::testing::InitGoogleTest(&argc, argv);
        return RUN_ALL_TESTS();
    }
  '';
  testFail = pkgs.writeText "fail.cc" ''
    #include <gtest/gtest.h>

    TEST (PassingTest, Passing)
    {
        EXPECT_EQ(1, 0);
    }

    int main(int argc, char **argv)
    {
        ::testing::InitGoogleTest(&argc, argv);
        return RUN_ALL_TESTS();
    }
  '';
in
{
  machine = { config, pkgs, ... }: {
    cri.packages.pkgs.dev.enable = true;
  };

  testScript = ''
    start_all()
    machine.succeed("g++ ${testSuccess} -lgtest -o success")
    machine.succeed("./success")
    machine.succeed("g++ ${testFail} -lgtest -o fail")
    machine.fail("./fail")
  '';
}
