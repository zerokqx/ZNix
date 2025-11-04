{ pkgs, ... }: {

  home.packages = with pkgs; [
    cargo
    git-crypt
    bun
    rustc
    loupe
    fastfetch
    nixfmt-classic
    devenv
    statix
    sqlfluff
    postgresql_17_jit
    xdg-user-dirs
  ];
}
