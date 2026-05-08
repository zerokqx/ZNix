{ lib, ... }:
{

  programs.alacritty = {
    enable = true;
    settings = {
      general.live_config_reload = true;
      window = {
        padding = {
          x = 12;
          y = 10;
        };
        dynamic_padding = true;
        opacity = lib.mkForce 1.0;
      };
      cursor = {
        unfocused_hollow = true;
        style = {
          shape = "Beam";
          blinking = "On";
        };
      };
      scrolling.history = 15000;
      selection.save_to_clipboard = true;
      mouse.hide_when_typing = true;
    };
  };
}
