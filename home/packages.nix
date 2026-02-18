{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [

    inputs.codex-cli-nix.packages.${pkgs.system}.default
    gh
    opencode
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
    insomnia
    git-crypt
    bun
    fastfetch
    devenv
    xdg-user-dirs
  ];
}
