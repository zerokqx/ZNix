{ lib, config, ... }:
let
  noctaliaMonitorsRaw = lib.attrByPath [ "znix" "monitors" "noctaliaMonitors" ] null config;
  noctaliaMonitors =
    if noctaliaMonitorsRaw == null then
      null
    else if lib.isList noctaliaMonitorsRaw then
      noctaliaMonitorsRaw
    else
      [ noctaliaMonitorsRaw ];
in
{
  programs.noctalia-shell = {
    enable = true;
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];

      states = {
        pomodoro = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };

      version = 2;
    };
    settings = {
      dock = {
        enabled = false;
      };
      location = {
        name = "Moscow";
      };
      wallpaper = {
        recursiveSearch = true;
      };
      notifications = {
        enableKeyboardLayoutToast = false;
      };
      general = {
        enableShadows = false;
      };
      bar = {
        showCapsule = false;
        density = "comfortable";
        position = lib.mkDefault "top";
        widgets = {
          left = [

            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {

              id = "WiFi";
            }
            {
              id = "Bluetooth";
            }

            {
              id = "NotifactionHistory";
            }
            {
              id = "KeyboardLayout";
              showIcon = false;
            }
          ];
          center = [

            {
              hideUnoccupied = false;

              id = "Workspace";
              labelMode = "index";
            }
          ];
          right = [
            {
              id = "Tray";
            }
            {
              alwaysShowPercentage = true;
              id = "Battery";
              warningThreshold = 30;
            }
            {
              id = "SystemMonitor";
            }
            {
              id = "Clock";
            }
          ];
        };
        monitors = noctaliaMonitors;
      };
      appLauncher = {
        enableClipboardHistory = true;
      };
    };
  };
}
