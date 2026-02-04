{ pkgs, ... }:
{

  home.packages = with pkgs; [
    opencode
    codex
    statix
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
