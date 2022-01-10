{ pkgs, ... }:

{
  machine = { config, pkgs, ... }: {
    cri.nswrappers.enable = true;

    users.users.alice = {
      isNormalUser = true;
      group = "students";
    };
    users.groups.students = {
      gid = 15000;
    };
  };

  testScript = ''
    start_all()
    machine.succeed("su - alice -c 'sudo ns-init test-ns'")
    machine.succeed("ip netns ls | grep test-ns")
    machine.succeed("su - epita  -c 'sudo ns-init test2-ns'")
    machine.succeed("ip netns ls | grep test22-ns")
  '';
}
