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
    sqlfluff
    postgresql_17_jit
    xdg-user-dirs
  ];
}
