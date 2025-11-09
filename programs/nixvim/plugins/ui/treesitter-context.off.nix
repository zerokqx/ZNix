{
  plugins.treesitter-context = {
    enable = true;
    settings = {
      line_numbers = true;
      max_lines = 0;
      min_window_height = 0;
      mode = "topline";
      multiline_threshold = 20;
      separator = "─";
      trim_scope = "inner";
      zindex = 20;
    };
  };
}
