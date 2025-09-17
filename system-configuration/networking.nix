{ ... }: {

  networking = {
    nameservers = [ "8.8.8.8" ];
    hostName = "nixos";
    networkmanager.enable = true;
  };
}
