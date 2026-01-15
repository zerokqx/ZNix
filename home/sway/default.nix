{ lib, pkgs, ... }:
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
      corner_radius 10
      shadows enable
      shadow_blur_radius 20
      blur_radius 5
      blur enable
      layer_effects "waybar" blur enable; corner_radius 10
      default_dim_inactive 0.1

      set $window_opacity 0.9
      for_window [app_id=".*"] opacity $window_opacity
      for_window [class=".*"] opacity $window_opacity

    '';
    config = rec {
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

      window.border = 1;
      window = {
        titlebar = false;
      };

      workspaceOutputAssign = [
        {
          workspace = "2";
          output = "DP-1";
        }
        {
          workspace = "3";
          output = "HDMI-A-1";
        }
        {
          workspace = "9";
          output = "HDMI-A-1";
        }
      ];

    };
  };
}
