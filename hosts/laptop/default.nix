{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    {
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
      znix.hardware.fingerprint.goodix.enable = false;

      # boot.kernelParams = [
      #   "psmouse.synaptics_intertouch=0"
      #   "psmouse.elantech_smbus=0"
      # ];

      home-manager.users.zerok = {
        programs.dank-material-shell.enable = true;
        znix.browser.enable = true;

        wayland.windowManager.hyprland.settings.monitor = [
          "eDP-1,1920x1080@60,0x0,1"
          "HDMI-A-2,1920x1080@60,1920x0,1"
        ];
      };
    }
  ];
}
