{ lib, config, ... }:
let
  sway = config.wayland.windowManager.sway.config;

  browserExe = lib.getExe config.znix.browser.package;
  noctaliaIpc = "noctalia-shell ipc call";
  m = sway.modifier;
  terminal = sway.terminal;
  menu = sway.menu;
in
{

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {

    "${m}+Shift+Return" = "exec ${terminal}";
    "${m}+d" = "exec ${noctaliaIpc} launcher toggle";
    "${m}+Cyrillic_ve" = "exec ${noctaliaIpc} launcher toggle";
    "Super+Alt+s" = "exec pkill orca || exec orca";

    "XF86AudioRaiseVolume" = "exec ${noctaliaIpc} volume increase";
    "XF86AudioLowerVolume" = "exec ${noctaliaIpc} volume decrease";
    "XF86AudioMute" = "exec ${noctaliaIpc} volume muteOutput";
    "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    "XF86AudioNext" = "exec ${noctaliaIpc} media next";
    "XF86AudioPrev" = "exec ${noctaliaIpc} media previous";
    "XF86AudioStop" = "exec playerctl stop";
    "Prior" = "exec ${noctaliaIpc} media next";
    "Next" = "exec ${noctaliaIpc} media playPause";
    "End" = "exec ${noctaliaIpc} media previous";
    "XF86AudioPlay" = "exec ${noctaliaIpc} media play";
    "XF86AudioPause" = "exec ${noctaliaIpc} media pause";
    "XF86MonBrightnessUp" = "exec ${noctaliaIpc} brightness increase";
    "XF86MonBrightnessDown" = "exec ${noctaliaIpc} brightness decrease";

    "${m}+Shift+c" = "kill";
    "${m}+b" = "exec ${browserExe}";
    "${m}+e" = "exec thunar";
    "${m}+v" = "exec ${noctaliaIpc} launcher clipboard";
    "${m}+q" = "exec ${terminal}";
    "${m}+d" = "exec ${menu}";

    "${m}+Left" = "focus left";
    "${m}+Down" = "focus down";
    "${m}+Up" = "focus up";
    "${m}+Right" = "focus right";
    "${m}+h" = "focus left";
    "${m}+j" = "focus down";
    "${m}+k" = "focus up";
    "${m}+l" = "focus right";

    "${m}+Ctrl+Left" = "move left";
    "${m}+Ctrl+Down" = "move down";
    "${m}+Ctrl+Up" = "move up";
    "${m}+Ctrl+Right" = "move right";
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

    "${m}+Shift+Left" = "focus output left";
    "${m}+Shift+Down" = "focus output down";
    "${m}+Shift+Up" = "focus output up";
    "${m}+Shift+Right" = "focus output right";
    "${m}+Shift+Ctrl+Left" = "move container to output left";
    "${m}+Shift+Ctrl+Down" = "move container to output down";
    "${m}+Shift+Ctrl+Up" = "move container to output up";
    "${m}+Shift+Ctrl+Right" = "move container to output right";
    "${m}+Shift+Ctrl+h" = "move container to output left";
    "${m}+Shift+Ctrl+j" = "move container to output down";
    "${m}+Shift+Ctrl+k" = "move container to output up";
    "${m}+Shift+Ctrl+l" = "move container to output right";

    "${m}+Page_Down" = "workspace next";
    "${m}+Page_Up" = "workspace prev";
    "${m}+u" = "workspace next";
    "${m}+i" = "workspace prev";
    "${m}+Alt+Down" = "workspace next";
    "${m}+Alt+Up" = "workspace prev";
    "${m}+Alt+j" = "workspace next";
    "${m}+Alt+k" = "workspace prev";

    "${m}+Ctrl+Page_Down" = "move container to workspace next";
    "${m}+Ctrl+Page_Up" = "move container to workspace prev";
    "${m}+Ctrl+u" = "move container to workspace next";
    "${m}+Ctrl+i" = "move container to workspace prev";

    "${m}+1" = "workspace number 1";
    "${m}+2" = "workspace number 2";
    "${m}+3" = "workspace number 3";
    "${m}+4" = "workspace number 4";
    "${m}+5" = "workspace number 5";
    "${m}+6" = "workspace number 6";
    "${m}+7" = "workspace number 7";
    "${m}+8" = "workspace number 8";
    "${m}+9" = "workspace number 9";

    "${m}+Shift+1" = "move container to workspace number 1";
    "${m}+Shift+2" = "move container to workspace number 2";
    "${m}+Shift+3" = "move container to workspace number 3";
    "${m}+Shift+4" = "move container to workspace number 4";
    "${m}+Shift+5" = "move container to workspace number 5";
    "${m}+Shift+6" = "move container to workspace number 6";
    "${m}+Shift+7" = "move container to workspace number 7";
    "${m}+Shift+8" = "move container to workspace number 8";
    "${m}+Shift+9" = "move container to workspace number 9";
    "${m}+Ctrl+1" = "move container to workspace number 1";
    "${m}+Ctrl+2" = "move container to workspace number 2";
    "${m}+Ctrl+3" = "move container to workspace number 3";
    "${m}+Ctrl+4" = "move container to workspace number 4";
    "${m}+Ctrl+5" = "move container to workspace number 5";
    "${m}+Ctrl+6" = "move container to workspace number 6";
    "${m}+Ctrl+7" = "move container to workspace number 7";
    "${m}+Ctrl+8" = "move container to workspace number 8";
    "${m}+Ctrl+9" = "move container to workspace number 9";

    "${m}+f" = "fullscreen toggle";
    "${m}+Shift+f" = "fullscreen toggle";
    "${m}+Space" = "layout toggle split";

    "${m}+s" = "exec grimshot --notify savecopy area";
    "${m}+Shift+s" = "exec grimshot --notify savecopy screen";
    "${m}+Shift+a" = "exec grimshot --notify savecopy area";
    "${m}+Shift+w" = "exec grimshot --notify savecopy window";
    "${m}+Shift+BracketRight" = "exec ${noctaliaIpc} controlCenter toggle";
    "${m}+Shift+v" = "exec ${noctaliaIpc} launcher clipboard";
    "${m}+Shift+b" = "exec ${noctaliaIpc} bluetooth togglePanel";
    "${m}+Shift+n" = "exec ${noctaliaIpc} network togglePanel";
    "${m}+Shift+p" = "exec ${noctaliaIpc} sessionMenu toggle";
    "${m}+Shift+e" = "exec swaymsg exit";
    "Ctrl+Alt+Delete" = "exec swaymsg exit";
    "${m}+Shift+Pause" = "output * power off";
    # "${m}+Shift+l" = "exec ${noctaliaIpc} lockScreen lock";
  };
}
