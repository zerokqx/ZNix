{

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "comfortable";
        position = "left";
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
