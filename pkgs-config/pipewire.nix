{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pipewire
    wireplumber
    alsa-utils
    pamixer
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    wireplumber.enable = true;
  };

  services.pulseaudio.enable = false;
}
