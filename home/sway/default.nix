{ pkgs, lib, config, ... }:
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
  ];
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    package = pkgs.swayfx;
    checkConfig = false;
    extraConfig = ''
      corner_radius 25
      shadows enable
      shadow_blur_radius 20
      default_dim_inactive 0.1
      blur enable
      blur_xray disable
      blur_radius 8
      blur_passes 3
      for_window [app_id=".*"] opacity 0.92
      for_window [floating] border normal
    '';
    config = {
      bars = [ ];
      modifier = "Mod4";
      terminal = "$TERM";
      menu = "noctalia-shell ipc call launcher toggle";
      defaultWorkspace = "1";
      bindkeysToCode = true;
      gaps = {
        inner = 8;
        outer = 12;
      };
      window.border = 0;
      window = {
        titlebar = false;
      };

      workspaceOutputAssign = workspaceAssignments;

    };
  };
}
