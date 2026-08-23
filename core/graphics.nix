
{ pkgs, ... }:
{
  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      intel-media-driver
      intel-vaapi-driver
      onevpl-intel-gpu
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

}
