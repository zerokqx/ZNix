{ lib, config, ... }:
let
  sway = config.wayland.windowManager.sway.config;
  m = sway.modifier;
  terminal = config.home.sessionVariables.TERMINAL or "foot";
  browserExe = lib.getExe config.znix.browser.package;
  dmsIpc = "dms ipc call";

  workspaceNumberBinds = builtins.listToAttrs (
    builtins.concatLists (
      builtins.genList (
        index:
        let
          ws = toString (index + 1);
          key = toString (if ws == "10" then 0 else (index + 1));
        in
        [
          {
            name = "${m}+${key}";
            value = "workspace number ${ws}";
          }
          {
            name = "${m}+Shift+${key}";
            value = "move container to workspace number ${ws}";
          }
        ]
      ) 10
    )
  );
in
{
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault (
    workspaceNumberBinds
    // {
      "${m}+Shift+Return" = "exec ${terminal}";
      "${m}+q" = "exec ${terminal}";
      "${m}+d" = "exec ${dmsIpc} launcher toggle";
      "${m}+Cyrillic_ve" = "exec ${dmsIpc} launcher toggle";

      "${m}+Shift+c" = "kill";
      "${m}+b" = "exec ${browserExe}";
      "${m}+e" = "exec thunar";
      "${m}+v" = "exec ${dmsIpc} clipboard toggle";
      "${m}+f" = "fullscreen toggle";

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

      "${m}+u" = "workspace next";
      "${m}+i" = "workspace prev";
      "${m}+Alt+Down" = "workspace next";
      "${m}+Alt+Up" = "workspace prev";
      "${m}+Alt+j" = "workspace next";
      "${m}+Alt+k" = "workspace prev";

      "${m}+s" = "scratchpad show";
      "${m}+Shift+s" = "exec dms screenshot full";
      "${m}+Shift+a" = "exec dms screenshot region";
      "${m}+Shift+w" = "exec dms screenshot window";
      "${m}+Shift+BracketRight" = "exec ${dmsIpc} control-center toggle";
      "${m}+Shift+v" = "exec ${dmsIpc} clipboard toggle";
      "${m}+Shift+b" = "exec ${dmsIpc} control-center toggle";
      "${m}+Shift+n" = "exec ${dmsIpc} settings toggleWith network";
      "${m}+Shift+p" = "exec ${dmsIpc} powermenu toggle";
      "${m}+Shift+e" = "exec swaymsg exit";
      "Ctrl+Alt+Delete" = "exec swaymsg exit";
      "${m}+Shift+Pause" = "output * power off";

      "XF86AudioRaiseVolume" = "exec ${dmsIpc} audio increment 5";
      "XF86AudioLowerVolume" = "exec ${dmsIpc} audio decrement 5";
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
      "XF86MonBrightnessUp" = "exec ${dmsIpc} brightness increment 5 \"\"";
      "XF86MonBrightnessDown" = "exec ${dmsIpc} brightness decrement 5 \"\"";
    }
  );
}
