{ pkgs, lib, config, ... }:
let
  cfg = config.services.zapret;
  whitelistFile = pkgs.writeText "zapret-whitelist" (lib.concatStringsSep "\n" [
    "youtube.com"
    "googlevideo.com"
    "ytimg.com"
    "ggpht.com"
    "youtu.be"
    "youtube-nocookie.com"
    "cloudflare-ech.com"
    "encryptedsni.com"
    "cloudflareaccess.com"
    "cloudflareapps.com"
    "cloudflarebolt.com"
    "cloudflareclient.com"
    "cloudflareinsights.com"
    "cloudflareok.com"
    "cloudflarepartners.com"
    "cloudflareportal.com"
    "cloudflarepreview.com"
    "cloudflareresolve.com"
    "cloudflaressl.com"
    "cloudflarestatus.com"
    "cloudflarestorage.com"
    "cloudflarestream.com"
    "cloudflaretest.com"
    "cloudfront.net"
    "dis.gd"
    "discord-attachments-uploads-prd.storage.googleapis.com"
    "discord.app"
    "discord.co"
    "discord.com"
    "discord.design"
    "discord.dev"
    "discord.gift"
    "discord.gifts"
    "discord.gg"
    "discord.media"
    "discord.new"
    "discord.store"
    "discord.status"
    "discord-activities.com"
    "discordactivities.com"
    "discordapp.com"
    "discordapp.net"
    "discordcdn.com"
    "discordmerch.com"
    "discordpartygames.com"
    "discordsays.com"
    "discordsez.com"
    "discordstatus.com"
    "frankerfacez.com"
    "gemini.google.com"
    "ai.google.dev"
    "generativelanguage.googleapis.com"
    "alkalimeteor-pa.clients6.google.com"
    "proactivebackend-pa.googleapis.com"
    "accounts.google.com"
    "ssl.gstatic.com"
    "www.gstatic.com"
    "ffzap.com"
    "betterttv.net"
    "7tv.app"
    "7tv.io"
    "localizeapi.com"
    "klipy.com"
    "live-video.net"
    # Roblox
    "roblox.com"
    "rbxcdn.com"
    "robloxlabs.com"
    "rbxtrk.com"
    "roblox.co.uk"
    # Steam
    "steampowered.com"
    "steamcommunity.com"
    "steamgames.com"
    "steamusercontent.com"
    "steamcontent.com"
    "steamstatic.com"
    "akamaihd.net"
    "edgecast.net"
    "steamcdn-a.akamaihd.net"
    "cs.steampipe.net"
    "l.steamchina.com"
    "valve.net"
    "valvesoftware.com"
  ]);
in
{
  services.zapret = {
    enable = true;
    params = [
      # Profile 1 (TCP): Applies desync strategy only to whitelisted domains on TCP ports 80/443
      "--filter-tcp=80,443"
      "--hostlist=${whitelistFile}"
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-split-pos=method+2"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fooling=badsum"

      # Profile 2 (QUIC/UDP): Applies desync strategy to whitelisted domains on UDP port 443 (QUIC)
      "--new"
      "--filter-udp=443"
      "--hostlist=${whitelistFile}"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"
      "--dpi-desync-any-protocol"
      "--dpi-desync-fake-quic=${cfg.package}/usr/share/zapret/files/fake/quic_initial_www_google_com.bin"

      # Profile 3 (Discord UDP): Applies IP fragmentation (ipfrag2) to all UDP traffic on voice ports
      "--new"
      "--filter-udp=50000-65535"
      "--dpi-desync=ipfrag2"
      "--dpi-desync-any-protocol"
      "--dpi-desync-cutoff=d3"
    ];

    whitelist = [ ];
    blacklist = [ ];

    httpSupport = true;
    udpSupport = true;

    udpPorts = [
      "443"
      "50000:65535"
    ];

    configureFirewall = false; # Модуль использует POSTROUTING (для роутеров), нам нужен OUTPUT
  };

  # Правильные правила для локального хоста: OUTPUT (не POSTROUTING)
  networking.firewall.extraCommands = ''
    iptables -t mangle -I OUTPUT -p tcp -m multiport --dports 80,443 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 \
      -j NFQUEUE --queue-num 200 --queue-bypass
    iptables -t mangle -I OUTPUT -p udp --dport 443 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 \
      -j NFQUEUE --queue-num 200 --queue-bypass
    iptables -t mangle -I OUTPUT -p udp -m multiport --dports 49152:65535 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 \
      -j NFQUEUE --queue-num 200 --queue-bypass
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t mangle -D OUTPUT -p tcp -m multiport --dports 80,443 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 \
      -j NFQUEUE --queue-num 200 --queue-bypass 2>/dev/null || true
    iptables -t mangle -D OUTPUT -p udp --dport 443 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 \
      -j NFQUEUE --queue-num 200 --queue-bypass 2>/dev/null || true
    iptables -t mangle -D OUTPUT -p udp -m multiport --dports 49152:65535 \
      -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 \
      -m mark ! --mark 0x40000000/0x40000000 \
      -j NFQUEUE --queue-num 200 --queue-bypass 2>/dev/null || true
  '';
}

