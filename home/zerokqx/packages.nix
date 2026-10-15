{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [

    # inputs.vkpl.packages.${pkgs.stdenv.hostPlatform.system}.vkpl
    uv
    bun inputs.codex-cli-nix.packages.${pkgs.system}.default
    ghc
    gnumake
    python3
    kdePackages.kdenlive
    bottom
    ncpamixer
    inputs.lu.packages.${stdenv.hostPlatform.system}.default
    cargo
    dive
    psmisc
    file
    gh
    vesktop
    beekeeper-studio
    mongodb-compass
    scrcpy
    android-tools
    pnpm_11
    lsof
    redisinsight
    sshfs
    lazydocker
    lazyssh
    lazygit
    ayugram-desktop
    yazi
    zathura
    nodejs_22
    libreoffice
    qbittorrent
    insomnia
    obsidian
    fastfetch
    devenv
    xdg-user-dirs
    loupe
    totem
  ];
}
