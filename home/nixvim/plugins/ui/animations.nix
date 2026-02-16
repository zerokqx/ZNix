{
  plugins.smear-cursor.enable = true;
  plugins.neoscroll = {
    enable = true;
    settings = {
      cursor_scrolls_alone = true;
      easing_function = "sine";
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
