{ lib, config, ... }:
let
  sway = config.wayland.windowManager.sway.config;

  browserExe = lib.getExe config.znix.browser.package;
  dmsIpc = "dms ipc call";
  m = sway.modifier;
  terminal = sway.terminal;
in
{

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {

    "${m}+Shift+Return" = "exec ${terminal}";
    "${m}+d" = "exec ${dmsIpc} launcher toggle";
    "${m}+Cyrillic_ve" = "exec ${dmsIpc} launcher toggle";

    "XF86AudioRaiseVolume" = "exec ${dmsIpc} audio increment";
    "XF86AudioLowerVolume" = "exec ${dmsIpc} audio decrement";
    "XF86AudioMute" = "exec ${dmsIpc} audio mute";
    "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    "XF86AudioNext" = "exec ${dmsIpc} mpris next";
    "XF86AudioPrev" = "exec ${dmsIpc} mpris previous";
    "XF86AudioStop" = "exec playerctl stop";
    "Prior" = "exec ${dmsIpc} mpris next";
    "Next" = "exec ${dmsIpc} mpris playPause";
    "End" = "exec ${dmsIpc} mpris previous";
    "XF86AudioPlay" = "exec ${dmsIpc} mpris play";
    "XF86AudioPause" = "exec ${dmsIpc} mpris pause";
    "XF86MonBrightnessUp" = "exec ${dmsIpc} brightness increment";
    "XF86MonBrightnessDown" = "exec ${dmsIpc} brightness decrement";

    "${m}+Shift+c" = "kill";
    "${m}+b" = "exec ${browserExe}";
    "${m}+e" = "exec thunar";
    "${m}+v" = "exec ${dmsIpc} clipboard toggle";
    "${m}+q" = "exec ${terminal}";

    "${m}+h" = "focus left";
    "${m}+j" = "focus down";
    "${m}+k" = "focus up";
    "${m}+l" = "focus right";

    "${m}+Shift+h" = "move left";
    "${m}+Shift+j" = "move down";
    "${m}+Shift+k" = "move up";
    "${m}+Shift+l" = "move right";

    "${m}+Ctrl+h" = "resize shrink width 5 ppt";
    "${m}+Ctrl+j" = "resize grow height 5 ppt";
    "${m}+Ctrl+k" = "resize shrink height 5 ppt";
    "${m}+Ctrl+l" = "resize grow width 5 ppt";
    "${m}+minus" = "resize shrink width 10 ppt";
    "${m}+equal" = "resize grow width 10 ppt";
    "${m}+Shift+minus" = "resize shrink height 10 ppt";
    "${m}+Shift+equal" = "resize grow height 10 ppt";

    # "${m}+Shift+Left" = "focus output left";
    # "${m}+Shift+Down" = "focus output down";
    # "${m}+Shift+Up" = "focus output up";
    # "${m}+Shift+Right" = "focus output right";
    # "${m}+Shift+Ctrl+Left" = "move container to output left";
    # "${m}+Shift+Ctrl+Down" = "move container to output down";
    # "${m}+Shift+Ctrl+Up" = "move container to output up";
    # "${m}+Shift+Ctrl+Right" = "move container to output right";
    # "${m}+Shift+Ctrl+h" = "move container to output left";
    # "${m}+Shift+Ctrl+j" = "move container to output down";
    # "${m}+Shift+Ctrl+k" = "move container to output up";
    # "${m}+Shift+Ctrl+l" = "move container to output right";

    "${m}+u" = "workspace next";
    "${m}+i" = "workspace prev";
    "${m}+Alt+Down" = "workspace next";
    "${m}+Alt+Up" = "workspace prev";
    "${m}+Alt+j" = "workspace next";
    "${m}+Alt+k" = "workspace prev";



    "${m}+Shift+f" = "fullscreen toggle";

    "${m}+s" = "exec grimshot --notify savecopy area";
    "${m}+Shift+s" = "exec grimshot --notify savecopy screen";
    "${m}+Shift+a" = "exec grimshot --notify savecopy area";
    "${m}+Shift+w" = "exec grimshot --notify savecopy window";
    "${m}+Shift+BracketRight" = "exec ${dmsIpc} control-center toggle";
    "${m}+Shift+v" = "exec ${dmsIpc} clipboard toggle";
    "${m}+Shift+b" = "exec ${dmsIpc} control-center toggle";
    "${m}+Shift+n" = "exec ${dmsIpc} settings toggleWith network";
    "${m}+Shift+p" = "exec ${dmsIpc} powermenu toggle";
    "${m}+Shift+e" = "exec swaymsg exit";
    "Ctrl+Alt+Delete" = "exec swaymsg exit";
    "${m}+Shift+Pause" = "output * power off";
    # "${m}+Shift+l" = "exec ${dmsIpc} lockScreen lock";
  };
}
