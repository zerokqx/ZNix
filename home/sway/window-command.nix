let
  center = "floating enable, move position center, resize set 40ppt 80ppt";
  centerApps = [
    "wifi"
    "bluetooth"
    "volume"
  ];

in
{
  wayland.windowManager.sway.config.window.commands =
    (map (program: {
      command = center;
      criteria = {
        app_id = program;
      };
    }) centerApps)
    ++ [
      {
        command = center;
        criteria = {

          title = "Extension:.*";
        };
      }
    ];
}
