{ ... }:
{

  networking = {
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      5173
      3000
    ];
    firewall.enable = true;
    wireless.iwd.enable = false;
  };
}
