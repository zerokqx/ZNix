{ pkgs, ... }: {

  home.packages = with pkgs; [
    cargo
    git-crypt
    rustc
    loupe
    age
    lutris
    fastfetch
    nixfmt-classic
    xdg-user-dirs
  ];
}
