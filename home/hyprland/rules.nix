


{
  wayland.windowManager.hyprland.settings.windowrule = [
    "float on, match:title ^(Extension:.*)$"
    "center on, match:title ^(Extension:.*)$"
    "size 40% 80%, match:title ^(Extension:.*)$"
    "pin on, match:title ^(Extension:.*)$"
    "stay_focused on, match:title ^(Extension:.*)$"

    "float on, match:title ^(Picture-in-Picture)$"
    "size 600 300, match:title ^(Picture-in-Picture)$"
    "move 830 565, match:title ^(Picture-in-Picture)$"
    "pin on, match:title ^(Picture-in-Picture)$"

    "float on, match:class ^(imv)$"
    "center on, match:class ^(imv)$"
    "size 900 500, match:class ^(imv)$"

    "float on, match:class ^(mpv)$"
    "center on, match:class ^(mpv)$"
    "size 500 400, match:class ^(mpv)$"

    "match:class ^(com\\.ayugram\\.desktop|AyuGram|ayugram)$, workspace special:ayugram silent"
    "match:initial_class ^(com\\.ayugram\\.desktop|AyuGram|ayugram)$, workspace special:ayugram silent"
    "match:class ^(Throne|throne)$, workspace 10 silent"
    "match:initial_class ^(Throne|throne)$, workspace 10 silent"
  ];
}
