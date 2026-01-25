{ lib, config, ... }:
let
  sway = config.wayland.windowManager.sway.config;
  m = sway.modifier;
  terminal = sway.terminal;
  menu = sway.menu;
in
{

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {

    "XF86AudioRaiseVolume" = "exec noctalia-shell ipc call volume increase";
    "XF86AudioLowerVolume" = "exec noctalia-shell ipc call volume decrease";
    "XF86AudioMute" = "exec noctalia-shell ipc call volume muteOutput";
    "XF86AudioNext" = "exec noctalia-shell ipc call media next";
    "XF86AudioPrev" = "exec noctalia-shell ipc call media previous";
    "Prior" = "exec noctalia-shell ipc call media next";
    "Next" = "exec noctalia-shell ipc call media playPause";
    "End" = "exec noctalia-shell ipc call media previous";
    "XF86AudioPlay" = "exec  noctalia-shell ipc call media play";
    "XF86AudioPause" = "exec noctalia-shell ipc call media pause";
    "XF86MonBrightnessUp" = "exec noctalia-shell ipc call brightness increase";
    "XF86MonBrightnessDown" = "exec noctalia-shell ipc call brightness decrease";
    "${m}+q" = "exec ${terminal}";
    "${m}+c" = "exec swaymsg kill";
    "${m}+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
    "${m}+n" = "exec ${terminal} -T $EDITOR -e $EDITOR";
    "${m}+b" = "exec $BROWSER";
    "${m}+e" = "exec thunar";
    "${m}+r" = "exec ${menu}";
    "${m}+Shift+s" = "exec grimshot --notify savecopy screen";
    "${m}+Shift+a" = "exec grimshot --notify savecopy area";
    "${m}+Shift+w" = "exec grimshot --notify savecopy window";
    "${m}+Shift+c" = "exec noctalia-shell ipc call controlCenter toggle";
    "${m}+Shift+h" = "exec noctalia-shell ipc call launcher clipboard";
    "${m}+Shift+b" = "exec noctalia-shell ipc call bluetooth togglePanel";
    "${m}+Shift+n" = "exec noctalia-shell ipc call network togglePanel";
    "${m}+Shift+p" = "exec noctalia-shell ipc call sessionMenu toggle";
    "${m}+Shift+l" = "exec noctalia-shell ipc call lockScreen lock";
    "${m}+Shift+v" = "exec ${terminal} --class volume -e ncpamixer";
  };
}
