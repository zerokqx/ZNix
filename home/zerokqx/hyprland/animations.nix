{
  wayland.windowManager.hyprland.settings.animations = {
    enabled = true;
    bezier = [
      "rubber, 0.175, 0.885, 0.32, 1.275"
      "fluid, 0.1, 1.15, 0.2, 1.1"
      "bounce, 0.05, 0.9, 0.1, 1.1"
      "snap, 0.2, 1.0, 0.25, 1.0"
      "linear, 0.0, 0.0, 1.0, 1.0"
    ];

    animation = [
      "windows, 1, 5, rubber"
      "windowsIn, 1, 5, rubber, popin 70%"
      "windowsOut, 1, 4, snap, popin 80%"
      "windowsMove, 1, 5, rubber"
      "border, 1, 6, bounce"
      "borderangle, 1, 30, linear, loop"
      "fade, 1, 4, default"
      "layers, 1, 4, rubber"
      "layersIn, 1, 4, rubber, popin 75%"
      "layersOut, 1, 3, snap, popin 80%"
      "workspaces, 1, 5, fluid, slide"
      "specialWorkspace, 1, 5, rubber, slidevert"
    ];
  };
}
