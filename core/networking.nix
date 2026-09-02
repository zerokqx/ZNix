{ ... }:
{

  networking = {
    networkmanager.enable = true;
    firewall.trustedInterfaces = [
      "docker0"
      "br-+"
    ];
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
    firewall.checkReversePath = false;
  firewall.allowedUDPPorts = [ 8888 40000 ];
    firewall.allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27031;
      }
      {
        from = 27036;
        to = 27036;
      }
      {
        from = 4380;
        to = 4380;
      }
      {
        from = 3478;
        to = 3479;
      }
    ];
    hostName = "nixos";
    firewall.enable = true;
    wireless.iwd.enable = false;
  };

}
