{ lib, config, ... }:
let
  workspaceNumberBinds = builtins.concatLists (
    builtins.genList (
      index:
      let
        workspace = toString (index + 1);
        key = toString (if workspace == "10" then 0 else (index + 1));
      in
      [
        "$mod, ${key}, workspace, ${workspace}"
        "$mod SHIFT, ${key}, movetoworkspace, ${workspace}"
      ]
    ) 10
  );

  browserExe = lib.getExe config.znix.browser.package;
  dmsIpc = "dms ipc call";
  terminal = config.home.sessionVariables.TERMINAL or "alacritty";
in
{
  wayland.windowManager.hyprland.settings.bind = workspaceNumberBinds ++ [
    "$mod SHIFT, return, exec, ${terminal}"
    "$mod, d, exec, ${dmsIpc} launcher toggle"
    "$mod, cyrillic_ve, exec, ${dmsIpc} launcher toggle"

    "$mod SHIFT, c, killactive"
    "$mod, b, exec, ${browserExe}"
    "$mod, e, exec, thunar"
    "$mod, v, exec, ${dmsIpc} clipboard toggle"
    "$mod, q, exec, ${terminal}"

    "$mod, h, movefocus, l"
    "$mod, j, movefocus, d"
    "$mod, k, movefocus, u"
    "$mod, l, movefocus, r"

    "$mod SHIFT, h, movewindow, l"
    "$mod SHIFT, j, movewindow, d"
    "$mod SHIFT, k, movewindow, u"
    "$mod SHIFT, l, movewindow, r"

    "$mod CTRL, h, resizeactive, -5% 0"
    "$mod CTRL, j, resizeactive, 0 5%"
    "$mod CTRL, k, resizeactive, 0 -5%"
    "$mod CTRL, l, resizeactive, 5% 0"
    "$mod, minus, resizeactive, -10% 0"
    "$mod, equal, resizeactive, 10% 0"
    "$mod SHIFT, minus, resizeactive, 0 -10%"
    "$mod SHIFT, equal, resizeactive, 0 10%"

    "$mod, u, workspace, e+1"
    "$mod, i, workspace, e-1"
    "$mod ALT, down, workspace, e+1"
    "$mod ALT, up, workspace, e-1"
    "$mod ALT, j, workspace, e+1"
    "$mod ALT, k, workspace, e-1"

    "$mod, f, fullscreen"

    "$mod, s, togglespecialworkspace, ayugram"
    "$mod SHIFT, s, exec, dms screenshot full"
    "$mod SHIFT, a, exec, dms screenshot region"
    "$mod SHIFT, w, exec, dms screenshot window"
    "$mod SHIFT, bracketright, exec, ${dmsIpc} control-center toggle"
    "$mod SHIFT, v, exec, ${dmsIpc} clipboard toggle"
    "$mod SHIFT, b, exec, ${dmsIpc} control-center toggle"
    "$mod SHIFT, n, exec, ${dmsIpc} settings toggleWith network"
    "$mod SHIFT, p, exec, ${dmsIpc} powermenu toggle"
    "$mod SHIFT, e, exit"
    "CTRL ALT, Delete, exit"
    "$mod SHIFT, Pause, exec, hyprctl dispatch dpms off"
  ];

  wayland.windowManager.hyprland.settings.bindel = [
    ", XF86AudioRaiseVolume, exec, ${dmsIpc} audio increment 5"
    ", XF86AudioLowerVolume, exec, ${dmsIpc} audio decrement 5"
    ", XF86MonBrightnessUp, exec, ${dmsIpc} brightness increment 5 \"\""
    ", XF86MonBrightnessDown, exec, ${dmsIpc} brightness decrement 5 \"\""
  ];

  wayland.windowManager.hyprland.settings.bindl = [
    ", XF86AudioMute, exec, ${dmsIpc} audio mute"
    ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ", XF86AudioNext, exec, ${dmsIpc} mpris next"
    ", XF86AudioPrev, exec, ${dmsIpc} mpris previous"
    ", XF86AudioStop, exec, playerctl stop"
    ", Prior, exec, ${dmsIpc} mpris next"
    ", Next, exec, ${dmsIpc} mpris playPause"
    ", End, exec, ${dmsIpc} mpris previous"
    ", XF86AudioPlay, exec, ${dmsIpc} mpris play"
    ", XF86AudioPause, exec, ${dmsIpc} mpris pause"
  ];

  wayland.windowManager.hyprland.settings.bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];
}
