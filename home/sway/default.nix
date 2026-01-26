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
      corner_radius 25
      shadows enable
      shadow_blur_radius 20
      default_dim_inactive 0.1
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
