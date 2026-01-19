{ pkgs, ... }:
{

  home.packages = with pkgs; [
    spicetify-cli
    typescript
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
    qbittorrent
    prismlauncher
    obsidian
    matugen
    insomnia
    spotify
    git-crypt
    bun
    fastfetch
    devenv
    xdg-user-dirs
  ];
}
