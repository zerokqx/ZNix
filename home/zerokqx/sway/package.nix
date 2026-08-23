{ pkgs, ... }:
{
  home.packages = with pkgs; [
    autotiling-rs
    cliphist
    grim
    slurp
    sway-contrib.grimshot
  ];
}
