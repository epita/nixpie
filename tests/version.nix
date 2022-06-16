{ self, ... }:

# This also acts as a canary test.
{
  nodes.machine = { };

  testScript = ''
    machine.wait_for_unit("default.target")
    assert "${if (self ? rev) then self.rev else ""}" == machine.succeed("cat /etc/nixos-version")
  '';
}
