{ lib, config, ... }:
{
  programs.niri.settings = {
    layer-rules = [
      {
        matches = [
          {
            namespace = "^noctalia-wallpaper*";
          }
        ];
        place-within-backdrop = true;
      }
    ];

    overview.workspace-shadow.enable = false;

    cursor = {
      theme = lib.mkForce config.stylix.cursor.name;
      size = lib.mkForce config.stylix.cursor.size;
    };

    debug.honor-xdg-activation-with-invalid-serial = [ ];
    gestures.hot-corners.enable = false;

    hotkey-overlay.skip-at-startup = true;
    prefer-no-csd = true;
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
  };
}
