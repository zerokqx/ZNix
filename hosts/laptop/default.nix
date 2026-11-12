{
  imports = [
    ../../configuration.nix
    ../../profiles/workstation.nix
    ../../profiles/development.nix
    ../../profiles/personal.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-laptop";
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  znix.hardware.fingerprint.goodix.enable = false;

  home-manager.users.zerok = {
    wayland.windowManager.hyprland.settings.monitor = [
      "eDP-1,1920x1080@60,0x0,1.25"
      "HDMI-A-2,1920x1080@60,auto,1"
    ];
  };
}
