{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    autotiling-rs
    alacritty
    delta
    atool
    bat
    bc
    btop
    cliphist
    imv
    eza
    exfat
    fd
    ffmpeg
    fzf
    gnupg
    grim
    mpv
    interception-tools
    libnotify
    nix-ld
    pavucontrol
    p7zip
    playerctl
    polkit_gnome
    ripgrep
    slurp
    sway-contrib.grimshot
    swaylock
    tree
    udiskie
    unrar
    unzip
    usbutils
    wget
    wf-recorder
    wl-clipboard
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.tumbler
    xdg-utils
  ];

  environment.shells = with pkgs; [ fish ];
}
