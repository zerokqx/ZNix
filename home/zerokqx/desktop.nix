{ config, lib, ... }:
{
  imports = [
    ./dms.nix
    ./znix/stylix-celestia.nix
  ];

  assertions = [
    {
      assertion = config.programs.caelestia.enable != config.programs.dank-material-shell.enable;
      message = "Enable exactly one desktop shell: Caelestia or Dank Material Shell.";
    }
  ];

  # Both shells render their own wallpaper.
  stylix.targets.hyprland.hyprpaper.enable = lib.mkDefault false;

  programs.caelestia = {
    enable = lib.mkDefault true;
    # Hyprland starts the selected shell through exec-once.
    systemd.enable = false;
    cli.enable = true;

    settings = {
      general.idle = {
        # Preserve the existing session policy without automatic lock, DPMS or suspend.
        timeouts = lib.mkDefault [ ];
        lockBeforeSleep = lib.mkDefault false;
      };

      utilities.toasts.kbLayoutChanged = lib.mkDefault false;

      # Caelestia replaces the whole list. Keep the pinned defaults except for kbLayout.
      bar.statusIcons = lib.mkDefault [
        {
          id = "lockStatus";
          enabled = true;
        }
        {
          id = "audio";
          enabled = false;
        }
        {
          id = "microphone";
          enabled = false;
        }
        {
          id = "kbLayout";
          enabled = true;
        }
        {
          id = "network";
          enabled = true;
        }
        {
          id = "bluetooth";
          enabled = true;
        }
        {
          id = "battery";
          enabled = true;
        }
      ];
    };
  };
}
