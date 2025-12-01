{ ... }:
{

  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      5173
      1212
    ];
    firewall.allowedUDPPorts = [ 1212 ];
    firewall.enable = false;
    wireless.iwd.enable = false;
  };
}
