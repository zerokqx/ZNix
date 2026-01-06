{
  services.zapret = {
    enable = true;

    params = [
      "--dpi-desync=fake,disorder2"
      "--dpi-desync-ttl=1"
      "--dpi-desync-autottl=2"
    ];

    blacklist = [
      "discord.com"
      "youtube.com"
    ];

    httpSupport = true;
    udpSupport = true;
    udpPorts = [ "443" ];
    configureFirewall = true;
  };
}
