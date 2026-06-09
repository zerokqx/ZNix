{
  wayland.windowManager.hyprland.settings.animations = {
    enabled = true;
    bezier = [
      "spring, 0.18, 0.89, 0.22, 1.08"
      "snap, 0.22, 1.0, 0.36, 1.0"
      "soft, 0.25, 0.1, 0.25, 1.0"
    ];

    animation = [
      "windows, 1, 5, spring"
      "windowsIn, 1, 5, spring, popin 82%"
      "windowsOut, 1, 4, snap, popin 88%"
      "windowsMove, 1, 5, soft"
      "border, 1, 7, soft"
      "borderangle, 1, 8, soft"
      "fade, 1, 5, soft"
      "layers, 1, 6, soft"
      "workspaces, 1, 5, spring"
      "specialWorkspace, 1, 6, spring, slidevert"
    ];
  };
}
