let
  center = "floating enable, move position center, resize set 40ppt 80ppt";
  centerApps = [ "wifi" "bluetooth" ];

in (map (program: {
  command = center;
  criteria = { app_id = program; };
}) centerApps) ++ [ ]

