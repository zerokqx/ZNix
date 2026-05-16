{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [
    lsof
    redisinsight
    sshfs
    httpie
    lazydocker
    lazyssh
    lazyjournal
    lazysql
    google-chrome
    drawio
    rustc
    gcc
    cargo
    waypipe
    dotnet-sdk_8
    nil
    dotnet-aspnetcore_8
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    gh
    beekeeper-studio
    statix
    typescript
    cloudflared
    nixd

    lazygit
    ayugram-desktop
    yazi
    zathura
    vtsls
    sqlite
    nodejs_22
    libreoffice
    steam
    osu-lazer
    qbittorrent
    prismlauncher
    nerd-fonts.jetbrains-mono
    insomnia
    obsidian
    git-crypt
    bun
    fastfetch
    devenv
    xdg-user-dirs
    wl-clipboard
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
  ];
}
