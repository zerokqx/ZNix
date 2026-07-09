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
        enableShadows = true;
        radiusRatio = 0.66;
        iRadiusRatio = 0.57;
        boxRadiusRatio = 0;
        screenRadiusRatio = 0;
      };
      bar = rec {
        showCapsule = true;
        capsuleOpacity = lib.mkForce 0.4;
        floating = true;
        marginVertical = 15;
        marginHorizontal = marginVertical;
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
