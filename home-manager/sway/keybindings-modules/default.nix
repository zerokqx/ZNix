{ lib, pkgs, ... }: {
  imports = [ ./gesture.nix ];

  keybindings = let m = wayland.winowManager.sway.mod;

  in lib.mkOptionDefault {
    "${m}+v" = "exec ${terminal} --class clipse -e clipse";
    "${m}+c" = "exec swaymsg kill";
    "${m}+s" = "workspace special";
    "${m}+Alt+s" = "move container to workspace special";
    "${m}+w" = "nop";
    "${m}+r" = "exec ${menu}";
    "${m}+q" = "exec ${terminal}";
    "${m}+b" = "exec ${browser}";
    "${m}+n" = "exec kitty ${editor}";
    "${m}+Shift+s" = ''
      exec ${grim} -g "$(${slurp})" - | tee ~/Pictures/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png | wl-copy'';
    "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +1%";
    "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -1%";
    "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
    "Prior" = "exec playerctl next";
    "Next" = "exec playerctl play-pause";

    "End" = "exec playerctl previous";
    "${m}+Shift+b" = "exec sh ${pConfig}/bluetooth.sh";
    "${m}+Shift+p" = "exec sh ${pConfig}/power-wofi.sh";
    "${m}+Shift+m" = "exec swaylock";
    "${m}+Shift+n" = "exec ${nr}";
    "${m}+e" = "exec kitty yazi";

  };

}
