{
  wayland.windowManager.hyprland.settings = {
    layerrule = [
      "animation none, match:namespace ^(dms:.*|dms.*|quickshell|selection|hyprpicker)$"
    ];

    windowrule = [
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


    "float on, match:class ^(org\\.kde\\.kdenlive|kdenlive)$, match:title ^(?!.*Kdenlive).*$"
    "center on, match:class ^(org\\.kde\\.kdenlive|kdenlive)$, match:title ^(?!.*Kdenlive).*$"

    "float on, match:title ^(Параметры.*|Свойства.*|Создать проект|Настройки.*|Open File|Save File|Confirm.*|Warning.*)$"
    "center on, match:title ^(Параметры.*|Свойства.*|Создать проект|Настройки.*|Open File|Save File|Confirm.*|Warning.*)$"

    "match:class ^(com\\.ayugram\\.desktop|AyuGram|ayugram)$, workspace special:ayugram silent"
    "match:initial_class ^(com\\.ayugram\\.desktop|AyuGram|ayugram)$, workspace special:ayugram silent"
    "match:class ^(Mullvad VPN)$, workspace 10 silent"
    "match:initial_class ^(Mullvad VPN)$, workspace 10 silent"
  ];
};
}
