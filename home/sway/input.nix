{
  wayland.windowManager.sway.config.input = {

    "type:keyboard" = {
      xkb_layout = "us,ru";
      xkb_options = "grp:win_space_toggle,caps:escape";

    };
    "type:touchpad" = {
      tap = "enabled";
      tap_button_map = "lrm";
      dwt = "enabled";
      dwtp = "enabled";
      natural_scroll = "enabled";
    };
  };
}
