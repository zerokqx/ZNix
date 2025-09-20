{ config, lib, pkgs, ... }: {
  wayland.windowManager.sway = let
    input = import ./input.nix;
    output = import ./output.nix;
    commands = import ./window-command.nix;
    assigns = import ./assigns.nix;
    startup = import ./startup.nix;
    editor = "nvim";
    slurp = "${pkgs.slurp}/bin/slurp";
    grim = "${pkgs.grim}/bin/grim";
    nr = "${pkgs.normcap}/bin/normcap";
    browser = "firefox";
    pConfig = ../scripts;
  in {
    enable = true;

    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      menu = "wofi --show drun";
      defaultWorkspace = "1";
      bindkeysToCode = true;
      inherit input;
      inherit output;
      inherit assigns;
      window = { inherit commands; };
      inherit startup;

      workspaceOutputAssign = [
        {
          workspace = "2:code";
          output = "DP-1";
        }
        {
          workspace = "3:web";
          output = "HDMI-A-1";
        }
        {
          workspace = "9:chats";
          output = "HDMI-A-1";
        }
      ];
      keybindings = let m = modifier;
      in lib.mkOptionDefault {
        "${m}+v" =
          "exec cliphist list | wofi --dmenu | cliphist decode | wl-copy";
        "${m}+c" = "exec swaymsg kill";
        "${m}+s" = "workspace special";
        "${m}+Alt+s" = "move container to workspace special";
        "${m}+w" = "nop";
        "${m}+r" = "exec ${menu}";
        "${m}+q" = "exec ${terminal}";
        "${m}+b" = "exec ${browser}";
        "${m}+n" = "exec kitty --title nvim ${editor}";
        "${m}+Shift+s" = ''
          exec ${grim} -g "$(${slurp})" - | tee ~/Pictures/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy'';
        "XF86AudioRaiseVolume" =
          "exec pactl set-sink-volume @DEFAULT_SINK@ +1%";
        "XF86AudioLowerVolume" =
          "exec pactl set-sink-volume @DEFAULT_SINK@ -1%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "Prior" = "exec playerctl next";
        "Next" = "exec playerctl play-pause";

        "End" = "exec playerctl previous";
        "${m}+Shift+b" = "exec  ${builtins.toString pConfig}/bluetooth.sh";
        "${m}+Shift+p" = "exec  ${builtins.toString pConfig}/power-wofi.sh";
        "${m}+Shift+m" = "exec swaylock";
        "${m}+Shift+n" = "exec ${nr}";
        "${m}+e" = "exec kitty yazi";

        "XF86MonBrightnessDown" = "exec brightnessctl s  10%+";
        "XF86MonBrightnessUp" = "exec brigtnessctl s 10%-";
      };
    };
  };

}
