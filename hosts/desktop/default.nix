{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix
    inputs.codex-desktop-linux.nixosModules.default
    ./hardware-configuration.nix
    ./virtual.nix
    ./wine.nix
    ({ pkgs, ... }: {
      networking.hostName = "nixos-pc";
      swapDevices = [
        {
          device = "/home/swapfile";
          size = 32 * 1024;
        }
      ];
      boot.resumeDevice = "/dev/disk/by-uuid/1a87da15-a5a7-463b-8ded-7d0cc826b5ea";
      boot.kernelParams = [ "resume_offset=147411171" ];
      # logind must see /home/swapfile to allow hibernation
      systemd.services.systemd-logind.serviceConfig.ProtectHome = "read-only";
      programs.codexDesktopLinux.enable = true;
      environment.systemPackages = [ pkgs.mullvad-vpn ];
      services.mullvad-vpn = {
        enable = true;
      };
      home-manager.users.zerok = {
        wayland.windowManager.hyprland.settings = {
          monitor = [
            "DP-1,1920x1080@165,1920x0,1"
            "HDMI-A-1,1920x1080@75,0x0,1"
          ];
          workspace = [
            "2,monitor:DP-1"
            "3,monitor:HDMI-A-1"
            "9,monitor:HDMI-A-1"
          ];
        };
      };
    })
  ];
}
