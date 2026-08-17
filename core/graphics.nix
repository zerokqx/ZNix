
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
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

}
