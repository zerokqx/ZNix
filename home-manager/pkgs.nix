{ pkgs, ... }: {

  home.packages = with pkgs; [
    cargo
    git-crypt
    rustc
    loupe
    lutris
    fastfetch
    nixfmt-classic
    xdg-user-dirs
  ];
}
