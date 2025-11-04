{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mesa amdvlk vaapiVdpau libvdpau-va-gl ];
  };

}
