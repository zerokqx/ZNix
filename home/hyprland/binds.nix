{ lib, config, ... }:
let
  workspaceNumberBinds = builtins.concatLists (
    builtins.genList
      (index:
        let
          workspace = builtins.toString (index + 1);
          key = builtins.toString (if workspace == "10" then 0 else (index + 1));
        in
        [
          "$mod, ${key}, workspace, ${workspace}"
          "$mod SHIFT, ${key}, movetoworkspace, ${workspace}"
        ])
      10
  );

  browserExe = lib.getExe config.znix.browser.package;
  noctaliaIpc = "noctalia-shell ipc call";
  terminal = config.home.sessionVariables.TERM or "alacritty";
in
{
  wayland.windowManager.hyprland.settings.bind =
    workspaceNumberBinds
    ++ [
      "$mod SHIFT, return, exec, ${terminal}"
      "$mod, d, exec, ${noctaliaIpc} launcher toggle"
      "$mod, cyrillic_ve, exec, ${noctaliaIpc} launcher toggle"

      ", XF86AudioRaiseVolume, exec, ${noctaliaIpc} volume increase"
      ", XF86AudioLowerVolume, exec, ${noctaliaIpc} volume decrease"
      ", XF86AudioMute, exec, ${noctaliaIpc} volume muteOutput"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86AudioNext, exec, ${noctaliaIpc} media next"
      ", XF86AudioPrev, exec, ${noctaliaIpc} media previous"
      ", XF86AudioStop, exec, playerctl stop"
      ", Prior, exec, ${noctaliaIpc} media next"
      ", Next, exec, ${noctaliaIpc} media playPause"
      ", End, exec, ${noctaliaIpc} media previous"
      ", XF86AudioPlay, exec, ${noctaliaIpc} media play"
      ", XF86AudioPause, exec, ${noctaliaIpc} media pause"
      ", XF86MonBrightnessUp, exec, ${noctaliaIpc} brightness increase"
      ", XF86MonBrightnessDown, exec, ${noctaliaIpc} brightness decrease"

      "$mod SHIFT, c, killactive"
      "$mod, b, exec, ${browserExe}"
      "$mod, e, exec, thunar"
      "$mod, v, exec, ${noctaliaIpc} launcher clipboard"
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
      "$mod SHIFT, s, exec, grimshot --notify savecopy screen"
      "$mod SHIFT, a, exec, grimshot --notify savecopy area"
      "$mod SHIFT, w, exec, grimshot --notify savecopy window"
      "$mod SHIFT, bracketright, exec, ${noctaliaIpc} controlCenter toggle"
      "$mod SHIFT, v, exec, ${noctaliaIpc} launcher clipboard"
      "$mod SHIFT, b, exec, ${noctaliaIpc} bluetooth togglePanel"
      "$mod SHIFT, n, exec, ${noctaliaIpc} network togglePanel"
      "$mod SHIFT, p, exec, ${noctaliaIpc} sessionMenu toggle"
      "$mod SHIFT, e, exit"
      "CTRL ALT, Delete, exit"
      "$mod SHIFT, Pause, exec, hyprctl dispatch dpms off"
    ];

  wayland.windowManager.hyprland.settings.bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];
}
