{ lib, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      window_padding_width = 10;
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      scrollback_lines = 15000;
      mouse_hide_wait = "3.0";
      enable_audio_bell = false;
      confirm_os_window_close = 0;
    };
  };
}
