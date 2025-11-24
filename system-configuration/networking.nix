{ ... }:
{

  networking = {
    nameservers = [ "8.8.8.8" ];
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 5173 ];
    firewall.enable = true;
    wireless.iwd.enable = false;
  };
}
