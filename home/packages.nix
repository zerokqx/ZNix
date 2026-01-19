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
    nerd-fonts.jetbrains-mono
    antigravity
    insomnia
    git-crypt
    bun
    fastfetch
    devenv
    xdg-user-dirs
  ];
}
