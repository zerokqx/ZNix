{ lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkDefault [ ",preferred,auto,1" ];
  };
}
