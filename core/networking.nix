{ ... }:
{

  networking = {
    networkmanager = {
      enable = true;
      dns = "none"; # не даём NM управлять resolv.conf
    };
    firewall.trustedInterfaces = [
      "docker0"
      "br-+"
    ];
    nameservers = [
      "111.88.96.51"
      "111.88.96.50"
      # "8.8.8.8"
      # "1.1.1.1"
    ];
    firewall.checkReversePath = false;
    firewall.allowedUDPPorts = [
      8888
      40000
    ];
    firewall.enable = true;
    wireless.iwd.enable = false;
  };

}
