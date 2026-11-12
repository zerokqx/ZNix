{
  wayland.windowManager.hyprland.settings.animations = {
    enabled = true;
    bezier = [
      "motionOut, 0.19, 1, 0.22, 1"
      "motionIn, 0.4, 0, 0.2, 1"
      "spaces, 0.5, 0, 0.15, 1"
      "linear, 0, 0, 1, 1"
    ];

    animation = [
      # Тягучее торможение без отскока; масштаб и прозрачность синхронны.
      # fadeOut нужен и для времени жизни закрывающегося окна.
      "windows, 1, 6, motionOut"
      "windowsIn, 1, 6, motionOut, popin 88%"
      "fadeIn, 1, 6, motionOut"
      "windowsOut, 1, 4, motionIn, popin 94%"
      "fadeOut, 1, 4, motionIn"
      "windowsMove, 1, 6.5, motionOut"
      "border, 1, 3, linear"
      "borderangle, 0"

      # У Spaces общий разгон и торможение: оба рабочих стола движутся вместе.
      "workspaces, 1, 8, spaces, slide"
      "specialWorkspace, 1, 6.5, motionOut, slidevert 18%"
      "specialWorkspaceIn, 1, 6.5, motionOut, slidevert 18%"
      "specialWorkspaceOut, 1, 4.5, motionIn, slidevert 18%"

      # Панели DMS исключены из этих эффектов в rules.nix: у них своя анимация.
      "fade, 1, 3, linear"
      "fadeSwitch, 1, 3, linear"
      "fadeDim, 1, 4, linear"
      "layers, 1, 3, motionOut"
      "layersIn, 1, 3, motionOut, fade"
      "fadeLayersIn, 1, 3, motionOut"
      "layersOut, 1, 2.2, motionIn, fade"
      "fadeLayersOut, 1, 2.2, motionIn"
      "fadePopupsIn, 1, 2, motionOut"
      "fadePopupsOut, 1, 1.6, motionIn"
    ];
  };
}
