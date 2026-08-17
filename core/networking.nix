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
    firewall.allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27031;
      } # Основной диапазон Steam P2P
      {
        from = 27036;
        to = 27036;
      } # Steam Discovery
      {
        from = 4380;
        to = 4380;
      } # Steamworks P2P
      {
        from = 3478;
        to = 3479;
      } # STUN-порты для установки P2P соединения
    ];
    hostName = "nixos";
    firewall.enable = true;
    wireless.iwd.enable = false;
  };

}
