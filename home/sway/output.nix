{ lib, config, ... }:
let
  monitors = config.znix.monitors.list;
  mkOutput = name: spec: {
    inherit (spec) mode pos;
  };
in
{
  wayland.windowManager.sway.config.output =
    lib.mkIf (monitors != { }) (lib.mapAttrs mkOutput monitors);
}
