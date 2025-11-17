{ lib, config, ... }:
{
  plugins.yazi = {
    settings = {
      use_ya_for_events_reading = true; # нужно включить, иначе highlight_groups не работает
      floating_window_scaling_factor = .8;
      hovered_buffer = {
        fg = "NONE";
        bg = "NONE";
      };
    };
  };

}
