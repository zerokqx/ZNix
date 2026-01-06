{ config, ... }:
{
  plugins.neoscroll = {
    enable = false;
    settings = {
      cursor_scrolls_alone = true;
      easing_function = "quadratic";
      hide_cursor = true;
      mappings = [
        "<C-u>"
        "<C-d>"
        "<C-b>"
        "<C-f>"
        "<C-y>"
        "<C-e>"
        "zt"
        "zz"
        "zb"
      ];
      respect_scrolloff = false;
      stop_eof = true;
    };
  };
}
