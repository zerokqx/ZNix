{ pkgs, ... }:
{

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.pulseaudio.package = pkgs.pulseaudioFull;

  security.rtkit.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "wireplumber.settings" = {
      "bluetooth.autoswitch-to-headset-profile" = true;
      "bluetooth.use-persistent-storage" = false;
    };
    "monitor.bluez.properties" = {
      "bluez5.hfphsp-backend" = "native";
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "ldac" ];
      "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hsp_ag" "hfp_ag" ];
    };
    "monitor.bluez.rules" = [
      {
        matches = [
          {
            "device.name" = "~bluez_card.*";
          }
        ];
        actions = {
          update-props = {
            "bluez5.auto-connect" = [ "a2dp_sink" "hfp_ag" "hsp_ag" "a2dp_source" ];
          };
        };
      }
    ];
  };
}
