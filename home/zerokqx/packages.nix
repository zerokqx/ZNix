{ pkgs, inputs, ... }:
{

  home.packages = with pkgs; [

    ngrok
    # inputs.vkpl.packages.${pkgs.stdenv.hostPlatform.system}.vkpl
    uv
    bun
    (import inputs.nixpkgs-unstable {
      inherit (stdenv.hostPlatform) system;
      config.allowUnfree = true;
    }).chatgpt
    inputs.codex-cli-nix.packages.${stdenv.hostPlatform.system}.default
    ghc
    gnumake
    python3
    kdePackages.kdenlive
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
    zellij
    nodejs_22
    libreoffice
    fragments
    insomnia
    obsidian
    fastfetch
    devenv
    xdg-user-dirs
    loupe
    totem
    gnome-calendar
    sox
    libqalculate
    cachix
    claude-code
    playwright-mcp
    trash-cli
    quickshell
    tig
    atool
    bat
    bc
    btop
    imv
    eza
    fd
    ffmpeg
    fzf
    gnupg
    grim
    libnotify
    nautilus
    pavucontrol
    p7zip
    playerctl
    ripgrep
    slurp
    sway-contrib.grimshot
    tree
    unrar
    unzip
    wf-recorder
    wl-clipboard
  ];
}
