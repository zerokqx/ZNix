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
        enableShadows = false;
      };
      bar = {
        showCapsule = false;
        monitors = [ "DP-1" ];
        density = "comfortable";
        position = "top";
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

      };
      appLauncher = {
        enableClipboardHistory = true;
      };
    };
  };
}
