{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [
    dive
    ripgrep
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
    # httpie
    lazydocker
    lazyssh
    google-chrome
    # gh
    lazygit
    ayugram-desktop
    yazi
    zathura
    nodejs_22
    libreoffice
    steam
    qbittorrent
    nerd-fonts.jetbrains-mono
    insomnia
    obsidian
    fastfetch
    devenv
    xdg-user-dirs
    wl-clipboard
    loupe
    totem
  ];
}
