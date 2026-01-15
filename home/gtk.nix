{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

    iconTheme = {
      name = "Tela-dark"; # или Adwaita, Papirus-Dark, WhiteSur-dark и т.д.
      package = pkgs.tela-icon-theme; # если нет — замените на pkgs.papirus-icon-theme
    };

  };
}
