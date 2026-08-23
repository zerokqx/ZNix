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

      # 1. Отключение визуального и звукового колокольчика (Visual Bell Flash)
      enable_audio_bell = false;
      visual_bell_duration = "0.0";
      window_alert_on_bell = false;
      bell_on_tab = false;

      confirm_os_window_close = 0;

      # 2. Плавный и мгновенный Wayland рендеринг без черных вспышек
      linux_display_server = "wayland";
      wayland_titlebar_color = "background";
      repaint_delay = 6;
      input_delay = 1;
      sync_to_monitor = "yes";
      background_opacity = lib.mkForce "1.0";
    };
  };
}
