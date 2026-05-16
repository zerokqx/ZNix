{ pkgs, inputs, ... }:
{
  programs.swaylock.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    settings = {
      "$mod" = "SUPER";
    };
  };
}
