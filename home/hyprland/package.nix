{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprland-qt-support
    hyprpwcenter
  ];
}
