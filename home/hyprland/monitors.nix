{ lib, config, ... }:
let
  monitors = config.znix.monitors.list;
  monitorNames = lib.sort builtins.lessThan (builtins.attrNames monitors);
  primary = if monitorNames == [ ] then null else builtins.head monitorNames;
  secondary = if lib.length monitorNames > 1 then builtins.elemAt monitorNames 1 else null;

  mkMonitor =
    name:
    let
      spec = monitors.${name};
      # Убираем "Hz" и заменяем на ".00", чтобы получить строгий float для герцовки (например, 1920x1080@165.00)
      rawMode = lib.removeSuffix "Hz" spec.mode;
      mode = if lib.hasInfix "@" rawMode then "${rawMode}.00" else rawMode;

      pos = builtins.replaceStrings [ " " ] [ "x" ] spec.pos;
    in
    "${name},${mode},${pos},${spec.scale}";

  monitorRules = if monitorNames == [ ] then [ ",preferred,auto,1" ] else map mkMonitor monitorNames;
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = monitorRules;

    workspace =
      lib.optionals (primary != null) [
        "2,monitor:${primary}"
      ]
      ++ lib.optionals (secondary != null) [
        "3,monitor:${secondary}"
        "9,monitor:${secondary}"
      ];
  };
}
