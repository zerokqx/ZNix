{ lib, ... }:
{
  plugins.mini-diff = {
    enable = true;
    settings = {

      delay = {
        text_change = 200;
      };
      mappings = {
        apply = "gh";
        goto_first = "[H";
        goto_last = "]H";
        goto_next = "]h";
        goto_prev = "[h";
        reset = "gH";
        textobject = "gh";
      };
      options = {
        algorithm = "histogram";
        indent_heuristic = true;
        linematch = 60;
        wrap_goto = false;
      };
      source = lib.nixvim.mkRaw "nil";
      view = {
        priority = 199;
        signs = {
          add = "▒";
          change = "▒";
          delete = "▒";
        };
        style = lib.nixvim.mkRaw "vim.go.number and 'number' or 'sign'";
      };
    };
  };
}
