{
  lib,
  config,
  pkgs,
  ...
}:
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

  browserExe = config.home.sessionVariables.BROWSER or "chromium";
  dmsIpc = "dms ipc call";
  caelestia = lib.getExe config.programs.caelestia.cli.package;
  shellIpc = "${lib.getExe config.programs.caelestia.package} ipc call";
  hyprshot = pkgs.hyprshot.override {
    hyprland = config.wayland.windowManager.hyprland.package;
  };
  shellActions =
    if config.programs.caelestia.enable then
      {
        launcher = "${shellIpc} drawers toggle launcher";
        clipboard = "${caelestia} clipboard";
        screenshotFull = "${caelestia} screenshot";
        screenshotRegion = "${caelestia} screenshot -r";
        screenshotWindow = "${lib.getExe hyprshot} -m window --clipboard-only";
        controlCenter = "${shellIpc} drawers toggle utilities";
        network = "${shellIpc} nexus open";
        power = "${shellIpc} drawers toggle session";
        volumeUp = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
        volumeDown = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        volumeMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        brightnessUp = "${shellIpc} brightness set +5%";
        brightnessDown = "${shellIpc} brightness set 5%-";
        media = "${shellIpc} mpris";
      }
    else
      {
        launcher = "${dmsIpc} launcher toggle";
        clipboard = "${dmsIpc} clipboard toggle";
        screenshotFull = "dms screenshot full";
        screenshotRegion = "dms screenshot region";
        screenshotWindow = "dms screenshot window";
        controlCenter = "${dmsIpc} control-center toggle";
        network = "${dmsIpc} settings toggleWith network";
        power = "${dmsIpc} powermenu toggle";
        volumeUp = "${dmsIpc} audio increment 5";
        volumeDown = "${dmsIpc} audio decrement 5";
        volumeMute = "${dmsIpc} audio mute";
        brightnessUp = "${dmsIpc} brightness increment 5 \"\"";
        brightnessDown = "${dmsIpc} brightness decrement 5 \"\"";
        media = "${dmsIpc} mpris";
      };
  terminal = config.home.sessionVariables.TERMINAL or "foot";
in
{
  wayland.windowManager.hyprland.settings.bind = workspaceNumberBinds ++ [
    "$mod SHIFT, return, exec, ${terminal}"
    "$mod, d, exec, ${shellActions.launcher}"
    "$mod, cyrillic_ve, exec, ${shellActions.launcher}"

    "$mod SHIFT, c, killactive"
    "$mod, b, exec, ${browserExe}"
    "$mod, e, exec, nautilus"
    "$mod, v, exec, ${shellActions.clipboard}"
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
    "$mod SHIFT, s, exec, ${shellActions.screenshotFull}"
    "$mod SHIFT, a, exec, ${shellActions.screenshotRegion}"
    "$mod SHIFT, w, exec, ${shellActions.screenshotWindow}"
    "$mod SHIFT, bracketright, exec, ${shellActions.controlCenter}"
    "$mod SHIFT, v, exec, ${shellActions.clipboard}"
    "$mod SHIFT, b, exec, ${shellActions.controlCenter}"
    "$mod SHIFT, n, exec, ${shellActions.network}"
    "$mod SHIFT, p, exec, ${shellActions.power}"
    "$mod SHIFT, e, exit"
    "CTRL ALT, Delete, exit"
    "$mod SHIFT, Pause, exec, hyprctl dispatch dpms off"

    "CTRL, F9, exec, whisrs toggle"
  ];

  wayland.windowManager.hyprland.settings.bindel = [
    ", XF86AudioRaiseVolume, exec, ${shellActions.volumeUp}"
    ", XF86AudioLowerVolume, exec, ${shellActions.volumeDown}"
    ", XF86MonBrightnessUp, exec, ${shellActions.brightnessUp}"
    ", XF86MonBrightnessDown, exec, ${shellActions.brightnessDown}"
  ];

  wayland.windowManager.hyprland.settings.bindl = [
    ", XF86AudioMute, exec, ${shellActions.volumeMute}"
    ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ", XF86AudioNext, exec, ${shellActions.media} next"
    ", XF86AudioPrev, exec, ${shellActions.media} previous"
    ", XF86AudioStop, exec, playerctl stop"
    ", Prior, exec, ${shellActions.media} next"
    ", Next, exec, ${shellActions.media} playPause"
    ", End, exec, ${shellActions.media} previous"
    ", XF86AudioPlay, exec, ${shellActions.media} play"
    ", XF86AudioPause, exec, ${shellActions.media} pause"
  ];

  wayland.windowManager.hyprland.settings.bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];
}
