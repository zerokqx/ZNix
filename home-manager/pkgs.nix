{ pkgs, ... }: {

  home.packages = with pkgs; [
    cargo
    git-crypt
    rustc
    loupe
    lutris
    fastfetch
    nixfmt-classic
    devenv
    xdg-user-dirs
  ];
}
