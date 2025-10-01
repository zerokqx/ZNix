{ ... }: {

  networking = {
    nameservers = [ "8.8.8.8" ];
    hostName = "nixos";
    networkmanager.enable = false;
    firewall.allowedTCPPorts = [ 5173 ]; # Разрешить порт 5173
    firewall.enable = true;
    wireless.iwd.enable = true;
  };
}
