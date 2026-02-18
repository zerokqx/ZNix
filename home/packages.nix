{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [

    inputs.codex-cli-nix.packages.${pkgs.system}.default
    
    opencode
    valent
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
    cartridges
    bun
    fastfetch
    devenv
    xdg-user-dirs
  ];
}
