{
  # node-exporter should be enabled by default
  machine = { };

  testScript = ''
    machine.wait_for_unit("prometheus-node-exporter.service")
    machine.wait_for_open_port(9100)
    machine.succeed("set -o pipefail; curl -vvv http://localhost:9100/metrics | grep nixpie_image")
  '';
}
