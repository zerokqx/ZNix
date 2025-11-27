{
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.sway =
    let
      input = import ./input.nix;
      output = import ./output.nix;
      commands = import ./window-command.nix;
      assigns = import ./assigns.nix;
      startup = import ./startup.nix;
      nr = "${pkgs.normcap}/bin/normcap";
      rofi = {
        calc = "${pkgs.rofi-calc}/bin/rofi-calc";
        bluetooth = "${pkgs.rofi-bluetooth}/bin/rofi-bluetooth";
        screenshot = "${pkgs.rofi-screenshot}/bin/rofi-screenshot";
        power = "${pkgs.rofi-power-menu}/bin/rofi-power-menu";
      };
    in
    {
      enable = true;

      config = rec {
        modifier = "Mod4";

        terminal = "$TERM";
        menu = "rofi -show drun";
        defaultWorkspace = "1";
        bindkeysToCode = true;
        inherit input;
        inherit output;
        inherit assigns;
        window = { inherit commands; };
        inherit startup;

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

        keybindings =
          let
            m = modifier;
          in
          lib.mkOptionDefault {
            "${m}+Shift+c" = "exec rofi -show calc -modi calc -no-show-match -no-sort";
            "${m}+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";

            "${m}+c" = "exec swaymsg kill";
            "${m}+r" = "exec ${menu}";
            "${m}+q" = "exec ${terminal}";
            "${m}+b" = "exec $BROWSER";
            "${m}+n" = "exec ${terminal} -T $EDITOR -e $EDITOR";

            "${m}+Shift+s" = "exec rofishot";

            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";

            # Медиа
            "Prior" = "exec playerctl next";
            "Next" = "exec playerctl play-pause";
            "End" = "exec playerctl previous";

            "${m}+Shift+b" = "exec ${rofi.bluetooth}";

            "${m}+Shift+p" = "exec rofi -show power-menu -modi power-menu:${rofi.power}";

            "${m}+Shift+m" = "exec swaylock";
            "${m}+Shift+n" = "exec ${nr}";

            # File manager
            "${m}+e" = "exec ${terminal} -e yazi";

            # WiFi manager
            "${m}+i" = "exec  rofi-network-manager";

            "XF86MonBrightnessDown" = "exec brightnessctl s 10%-";
            "XF86MonBrightnessUp" = "exec brightnessctl s 10%+";
            "${m}+Shift+v" = "exec ${terminal} --class volume -e ncpamixer";
          };
      };
    };
}
