{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [ mesa vaapiVdpau libvdpau-va-gl ];
  };

}
