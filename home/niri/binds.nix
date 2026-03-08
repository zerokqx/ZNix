{ lib, config, ... }:

let
  browserExe = lib.getExe config.znix.browser.package;
in
{
  programs.niri.settings.binds = {
    "Mod+Shift+Slash" = {
      action.show-hotkey-overlay = [ ];
    };
    "Mod+Return" = {
      action.spawn = "alacritty";
      hotkey-overlay.title = "Open a Terminal: alacritty";
    };
    "Mod+D" = {
      action.spawn-sh = "noctalia-shell ipc call launcher toggle";
      hotkey-overlay.title = "Run an Application: Noctalia launcher";
    };
    "Mod+B" = {
      action.spawn = "${browserExe}";
      hotkey-overlay.title = "Run an Application: Firefox";
    };
    "Mod+Cyrillic_ve" = {
      action.spawn-sh = "noctalia-shell ipc call launcher toggle";
    };
    "Super+Alt+S" = {
      action.spawn-sh = "pkill orca || exec orca";
      allow-when-locked = true;
      hotkey-overlay.hidden = true;
    };
    "XF86AudioRaiseVolume" = {
      action.spawn-sh = "noctalia-shell ipc call volume increase";
      allow-when-locked = true;
    };
    "XF86AudioLowerVolume" = {
      action.spawn-sh = "noctalia-shell ipc call volume decrease";
      allow-when-locked = true;
    };
    "XF86AudioMute" = {
      action.spawn-sh = "noctalia-shell ipc call volume muteOutput";
      allow-when-locked = true;
    };
    "XF86AudioMicMute" = {
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      allow-when-locked = true;
    };
    "XF86AudioPlay" = {
      action.spawn-sh = "noctalia-shell ipc call media play";
      allow-when-locked = true;
    };
    "XF86AudioPause" = {
      action.spawn-sh = "noctalia-shell ipc call media pause";
      allow-when-locked = true;
    };
    "XF86AudioStop" = {
      action.spawn-sh = "playerctl stop";
      allow-when-locked = true;
    };
    "XF86AudioPrev" = {
      action.spawn-sh = "noctalia-shell ipc call media previous";
      allow-when-locked = true;
    };
    "XF86AudioNext" = {
      action.spawn-sh = "noctalia-shell ipc call media next";
      allow-when-locked = true;
    };
    "Prior" = {
      action.spawn-sh = "noctalia-shell ipc call media next";
      allow-when-locked = true;
    };
    "Next" = {
      action.spawn-sh = "noctalia-shell ipc call media playPause";
      allow-when-locked = true;
    };
    "End" = {
      action.spawn-sh = "noctalia-shell ipc call media previous";
      allow-when-locked = true;
    };
    "XF86MonBrightnessUp" = {
      action.spawn-sh = "noctalia-shell ipc call brightness increase";
      allow-when-locked = true;
    };
    "XF86MonBrightnessDown" = {
      action.spawn-sh = "noctalia-shell ipc call brightness decrease";
      allow-when-locked = true;
    };
    "Mod+O" = {
      action.toggle-overview = [ ];
      repeat = false;
    };
    "Mod+X" = {
      action.close-window = [ ];
      repeat = false;
    };
    "Mod+E" = {
      action.spawn = "thunar";
    };
    "Mod+Left" = {
      action.focus-column-left = [ ];
    };
    "Mod+Down" = {
      action.focus-window-down = [ ];
    };
    "Mod+Up" = {
      action.focus-window-up = [ ];
    };
    "Mod+Right" = {
      action.focus-column-right = [ ];
    };
    "Mod+H" = {
      action.focus-column-left = [ ];
    };
    "Mod+J" = {
      action.focus-window-down = [ ];
    };
    "Mod+K" = {
      action.focus-window-up = [ ];
    };
    "Mod+L" = {
      action.focus-column-right = [ ];
    };
    "Mod+Ctrl+Left" = {
      action.move-column-left = [ ];
    };
    "Mod+Ctrl+Down" = {
      action.move-window-down = [ ];
    };
    "Mod+Ctrl+Up" = {
      action.move-window-up = [ ];
    };
    "Mod+Ctrl+Right" = {
      action.move-column-right = [ ];
    };
    "Mod+Ctrl+H" = {
      action.move-column-left = [ ];
    };
    "Mod+Ctrl+J" = {
      action.move-window-down = [ ];
    };
    "Mod+Ctrl+K" = {
      action.move-window-up = [ ];
    };
    "Mod+Ctrl+L" = {
      action.move-column-right = [ ];
    };
    "Mod+Home" = {
      action.focus-column-first = [ ];
    };
    "Mod+End" = {
      action.focus-column-last = [ ];
    };
    "Mod+Ctrl+Home" = {
      action.move-column-to-first = [ ];
    };
    "Mod+Ctrl+End" = {
      action.move-column-to-last = [ ];
    };
    "Mod+Shift+Left" = {
      action.focus-monitor-left = [ ];
    };
    "Mod+Shift+Down" = {
      action.focus-monitor-down = [ ];
    };
    "Mod+Shift+Up" = {
      action.focus-monitor-up = [ ];
    };
    "Mod+Shift+Right" = {
      action.focus-monitor-right = [ ];
    };
    "Mod+Shift+H" = {
      action.focus-monitor-left = [ ];
    };
    "Mod+Shift+J" = {
      action.focus-monitor-down = [ ];
    };
    "Mod+Shift+K" = {
      action.focus-monitor-up = [ ];
    };
    "Mod+Shift+L" = {
      action.focus-monitor-right = [ ];
    };
    "Mod+Shift+Ctrl+Left" = {
      action.move-column-to-monitor-left = [ ];
    };
    "Mod+Shift+Ctrl+Down" = {
      action.move-column-to-monitor-down = [ ];
    };
    "Mod+Shift+Ctrl+Up" = {
      action.move-column-to-monitor-up = [ ];
    };
    "Mod+Shift+Ctrl+Right" = {
      action.move-column-to-monitor-right = [ ];
    };
    "Mod+Shift+Ctrl+H" = {
      action.move-column-to-monitor-left = [ ];
    };
    "Mod+Shift+Ctrl+J" = {
      action.move-column-to-monitor-down = [ ];
    };
    "Mod+Shift+Ctrl+K" = {
      action.move-column-to-monitor-up = [ ];
    };
    "Mod+Shift+Ctrl+L" = {
      action.move-column-to-monitor-right = [ ];
    };
    "Mod+Page_Down" = {
      action.focus-workspace-down = [ ];
    };
    "Mod+Page_Up" = {
      action.focus-workspace-up = [ ];
    };
    "Mod+U" = {
      action.focus-workspace-down = [ ];
    };
    "Mod+I" = {
      action.focus-workspace-up = [ ];
    };
    "Mod+Alt+Down" = {
      action.focus-workspace-down = [ ];
    };
    "Mod+Alt+Up" = {
      action.focus-workspace-up = [ ];
    };
    "Mod+Alt+J" = {
      action.focus-workspace-down = [ ];
    };
    "Mod+Alt+K" = {
      action.focus-workspace-up = [ ];
    };
    "Mod+Ctrl+Page_Down" = {
      action.move-column-to-workspace-down = [ ];
    };
    "Mod+Ctrl+Page_Up" = {
      action.move-column-to-workspace-up = [ ];
    };
    "Mod+Ctrl+U" = {
      action.move-column-to-workspace-down = [ ];
    };
    "Mod+Ctrl+I" = {
      action.move-column-to-workspace-up = [ ];
    };
    "Mod+Shift+Page_Down" = {
      action.move-workspace-down = [ ];
    };
    "Mod+Shift+Page_Up" = {
      action.move-workspace-up = [ ];
    };
    "Mod+Shift+U" = {
      action.move-workspace-down = [ ];
    };
    "Mod+Shift+I" = {
      action.move-workspace-up = [ ];
    };
    "Mod+WheelScrollDown" = {
      action.focus-workspace-down = [ ];
      cooldown-ms = 150;
    };
    "Mod+WheelScrollUp" = {
      action.focus-workspace-up = [ ];
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollDown" = {
      action.move-column-to-workspace-down = [ ];
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollUp" = {
      action.move-column-to-workspace-up = [ ];
      cooldown-ms = 150;
    };
    "Mod+WheelScrollRight" = {
      action.focus-column-right = [ ];
    };
    "Mod+WheelScrollLeft" = {
      action.focus-column-left = [ ];
    };
    "Mod+Ctrl+WheelScrollRight" = {
      action.move-column-right = [ ];
    };
    "Mod+Ctrl+WheelScrollLeft" = {
      action.move-column-left = [ ];
    };
    "Mod+Shift+WheelScrollDown" = {
      action.focus-column-right = [ ];
    };
    "Mod+Shift+WheelScrollUp" = {
      action.focus-column-left = [ ];
    };
    "Mod+Ctrl+Shift+WheelScrollDown" = {
      action.move-column-right = [ ];
    };
    "Mod+Ctrl+Shift+WheelScrollUp" = {
      action.move-column-left = [ ];
    };
    "Mod+1" = {
      action.focus-workspace = 1;
    };
    "Mod+2" = {
      action.focus-workspace = 2;
    };
    "Mod+3" = {
      action.focus-workspace = 3;
    };
    "Mod+4" = {
      action.focus-workspace = 4;
    };
    "Mod+5" = {
      action.focus-workspace = 5;
    };
    "Mod+6" = {
      action.focus-workspace = 6;
    };
    "Mod+7" = {
      action.focus-workspace = 7;
    };
    "Mod+8" = {
      action.focus-workspace = 8;
    };
    "Mod+9" = {
      action.focus-workspace = 9;
    };
    "Mod+Ctrl+1" = {
      action.move-column-to-workspace = 1;
    };
    "Mod+Ctrl+2" = {
      action.move-column-to-workspace = 2;
    };
    "Mod+Ctrl+3" = {
      action.move-column-to-workspace = 3;
    };
    "Mod+Ctrl+4" = {
      action.move-column-to-workspace = 4;
    };
    "Mod+Ctrl+5" = {
      action.move-column-to-workspace = 5;
    };
    "Mod+Ctrl+6" = {
      action.move-column-to-workspace = 6;
    };
    "Mod+Ctrl+7" = {
      action.move-column-to-workspace = 7;
    };
    "Mod+Ctrl+8" = {
      action.move-column-to-workspace = 8;
    };
    "Mod+Ctrl+9" = {
      action.move-column-to-workspace = 9;
    };
    "Mod+BracketLeft" = {
      action.consume-or-expel-window-left = [ ];
    };
    "Mod+BracketRight" = {
      action.consume-or-expel-window-right = [ ];
    };
    "Mod+Comma" = {
      action.consume-window-into-column = [ ];
    };
    "Mod+Period" = {
      action.expel-window-from-column = [ ];
    };
    "Mod+R" = {
      action.switch-preset-column-width = [ ];
    };
    "Mod+Shift+R" = {
      action.switch-preset-window-height = [ ];
    };
    "Mod+Ctrl+R" = {
      action.reset-window-height = [ ];
    };
    "Mod+F" = {
      action.maximize-column = [ ];
    };
    "Mod+Shift+F" = {
      action.fullscreen-window = [ ];
    };
    "Mod+Ctrl+F" = {
      action.expand-column-to-available-width = [ ];
    };
    "Mod+C" = {
      action.center-column = [ ];
    };
    "Mod+Ctrl+C" = {
      action.center-visible-columns = [ ];
    };
    "Mod+Minus" = {
      action.set-column-width = "-10%";
    };
    "Mod+Equal" = {
      action.set-column-width = "+10%";
    };
    "Mod+Shift+Minus" = {
      action.set-window-height = "-10%";
    };
    "Mod+Shift+Equal" = {
      action.set-window-height = "+10%";
    };
    "Mod+V" = {
      action.spawn-sh = "noctalia-shell ipc call launcher clipboard";
    };
    "Mod+W" = {
      action.toggle-column-tabbed-display = [ ];
    };
    "Mod+Space" = {
      action.switch-layout = "next";
    };
    "Mod+S" = {
      action.screenshot = [ ];
    };
    "Mod+Shift+S" = {
      action.screenshot-screen = [ ];
    };
    "Mod+Shift+W" = {
      action.screenshot-window = [ ];
    };
    "Mod+Escape" = {
      action.toggle-keyboard-shortcuts-inhibit = [ ];
      allow-inhibiting = false;
    };
    "Mod+Shift+C" = {
      action.spawn-sh = "noctalia-shell ipc call controlCenter toggle";
    };
    "Mod+Shift+B" = {
      action.spawn-sh = "noctalia-shell ipc call bluetooth togglePanel";
    };
    "Mod+Shift+N" = {
      action.spawn-sh = "noctalia-shell ipc call network togglePanel";
    };
    "Mod+Shift+P" = {
      action.spawn-sh = "noctalia-shell ipc call sessionMenu toggle";
    };
    "Mod+Shift+E" = {
      action.quit = [ ];
    };
    "Ctrl+Alt+Delete" = {
      action.quit = [ ];
    };
    "Mod+Shift+Pause" = {
      action.power-off-monitors = [ ];
    };
  };
}
