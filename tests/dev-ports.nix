{
  name = "znix-dev-ports";
  defaults.virtualisation = {
    memorySize = 512;
    vlans = [
      1
      2
    ];
  };

  nodes = {
    server =
      { pkgs, ... }:
      {
        imports = [ ../core/znix/ports.nix ];
        environment.systemPackages = [ pkgs.python3 ];
        znix.dev.ports = {
          enable = true;
          interface = "eth1";
          tcpPorts = [ 18080 ];
        };
      };
    client = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.curl
        pkgs.netcat-openbsd
      ];
    };
  };

  testScript =
    { nodes, ... }:
    let
      address =
        interface: (builtins.head nodes.server.networking.interfaces.${interface}.ipv4.addresses).address;
    in
    ''
      start_all()
      server.wait_for_unit("firewall.service")

      for port in (18080, 18081):
          server.succeed(
              f"systemd-run --unit=dev-http-{port} $(command -v python3) "
              f"-m http.server --bind 0.0.0.0 --directory /tmp {port}"
          )
          server.wait_for_open_port(port)

      client.wait_until_succeeds("curl --fail --max-time 3 http://${address "eth1"}:18080/")
      client.fail("nc -z -w 3 ${address "eth1"} 18081")
      client.succeed("ping -c 1 ${address "eth2"}")
      client.fail("nc -z -w 3 ${address "eth2"} 18080")
    '';
}
