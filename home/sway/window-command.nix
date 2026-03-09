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
      {
        command = "floating enable, resize set width 600 px height 300 px, move position 830 px 565 px, sticky on";
        criteria = {
          title = "Picture-in-Picture";
        };
      }

      {
        command = "floating enable, move position center, resize set 900px 500px";
        criteria = {
          app_id = "imv";
        };
      }

      {
        command = "floating enable, move position center, resize set 500px 400px";
        criteria = {
          app_id = "mpv";
        };
      }

    ];
}
