{
  pkgs,
  lib,
  config,
  ...
}:

let
  monitorNames = lib.sort builtins.lessThan (builtins.attrNames config.znix.monitors.list);
  primary = if monitorNames == [ ] then null else builtins.head monitorNames;
  secondary = if (lib.length monitorNames > 1) then builtins.elemAt monitorNames 1 else null;
  workspaceAssignments =
    lib.optionals (primary != null) [
      {
        workspace = "2";
        output = primary;
      }
    ]
    ++ lib.optionals (secondary != null) [
      {
        workspace = "3";
        output = secondary;
      }
      {
        workspace = "9";
        output = secondary;
      }
    ];
in
{
  imports = [
    ./assigns.nix
    ./input.nix
    ./output.nix
    ./window-command.nix
    ./startup.nix
    ./keybindings.nix
    ./package.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true;

    config = {
      bars = [ ];
      modifier = "Mod4";
      terminal = config.home.sessionVariables.TERMINAL or "foot";
      menu = "dms ipc call launcher toggle";
      defaultWorkspace = "1";
      bindkeysToCode = true;
      gaps = {
        inner = 8;
        outer = 12;
      };
      window.border = 4;
      window = {
        titlebar = false;
      };

      workspaceOutputAssign = workspaceAssignments;
    };

    extraConfig = ''
      corner_radius 20
      smart_corner_radius on
      blur disable
      shadows disable
      default_dim_inactive 0.0
    '';
  };
}
