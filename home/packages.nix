{ pkgs, ... }:
{

  home.packages = with pkgs; [
    cargo
    git-crypt
    bun
    loupe
    fastfetch
    devenv
    xdg-user-dirs
  ];
}
