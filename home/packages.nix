{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [
    waypipe
    dotnet-sdk_8
    dotnet-aspnetcore_8
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    gh
    beekeeper-studio
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

  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
  ];
}
