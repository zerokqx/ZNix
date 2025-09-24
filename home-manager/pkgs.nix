{ pkgs, ... }: {

  home.packages = with pkgs; [
    cargo
    git-crypt
    bun
    rustc
    loupe
    lutris
    fastfetch
    nixfmt-classic
    devenv
    xdg-user-dirs
  ];
}
